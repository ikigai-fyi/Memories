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
            throw RequestError.unknown
        }
        
        guard scope.contains("activity:read_all") && scope.contains("profile:read_all")
        else {
            Analytics.capture(event: .receivedInvalidStravaOauthRedirect, eventProperties: [.cause: "invalid scope"])
            throw RequestError.unknown
        }
        
        Analytics.capture(event: .receivedValidStravaOauthRedirect)
        try await loginWithStrava(code: code, scope: scope)
    }
    
    private func loginWithStrava(code: String, scope: String) async throws {
        let login = try await Request(authenticated: false).post(
            Login.self,
            endpoint: "/auth/login/strava",
            payload: ["code": code, "scope": scope]
        )
        
        self.authManager.login(athlete: login.toAthlete())
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
