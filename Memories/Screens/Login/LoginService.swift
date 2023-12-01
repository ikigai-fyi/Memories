//
//  LoginService.swift
//  Memories
//
//  Created by Paul Nicolet on 01/12/2023.
//

import Foundation
import AuthenticationServices
import Sentry

class LoginService : NSObject {
    private let authManager = AuthManager.shared
    
    func startOauth(webCallback: @escaping (URL?, (any Error)?) -> Void) {
        if UIApplication.shared.canOpenURL(self.stravaMobileUrl) {
            Analytics.capture(event: .connectStrava, eventProperties: [.with: "stravaApp"])
            UIApplication.shared.open(self.stravaMobileUrl, options: [:])
        } else {
            Analytics.capture(event: .connectStrava, eventProperties: [.with: "stravaWebview"])
            let session = ASWebAuthenticationSession(url: self.stravaWebUrl, callbackURLScheme: "memories", completionHandler: webCallback)
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }
    
    func handleOauthRedirect(url: URL) async throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
              let scope = components.queryItems?.first(where: { $0.name == "scope" })?.value
        else {
            Analytics.capture(event: .receivedInvalidStravaOauthRedirect, eventProperties: [.cause: "invalid url"])
            throw GenericError.unknown
        }
        
        guard scope.contains("activity:read_all") && scope.contains("profile:read_all")
        else {
            Analytics.capture(event: .receivedInvalidStravaOauthRedirect, eventProperties: [.cause: "invalid scope"])
            throw GenericError.unknown
        }
        
        Analytics.capture(event: .receivedValidStravaOauthRedirect)
        await loginWithStrava(code: code, scope: scope)
    }
    
    private func loginWithStrava(code: String, scope: String) async {
        let url = URL(string: "\(Config.backendURL)/rest/auth/login/strava")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["code": code, "scope": scope]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.standard)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let decoded = try decoder.decode(Login.self, from: data)
            let athlete = decoded.toAthlete()
            self.authManager.login(athlete: athlete)
        } catch {
            SentrySDK.capture(error: error)
        }
    }
    
    private var stravaMobileUrl: URL {
        var components = URLComponents()
        components.scheme = "strava"
        components.host = "oauth"
        components.path = "/mobile/authorize"
        components.queryItems = self.stravaQueryItems
        return components.url!
    }
    
    private var stravaWebUrl: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.strava.com"
        components.path = "/oauth/mobile/authorize"
        components.queryItems = self.stravaQueryItems
        return components.url!
    }
    
    private var stravaQueryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "client_id", value: "106696"),
            URLQueryItem(name: "redirect_uri", value: "memories://ikigai.fyi"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "approval_prompt", value: "auto"),
            URLQueryItem(name: "scope", value: "activity:read_all,profile:read_all"),
            URLQueryItem(name: "state", value: "login"),
        ]
    }
}

extension LoginService : ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
