//
//  StravaLoginViewModel.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import Foundation
import AuthenticationServices
import WidgetKit
import PostHog
import Sentry

let appGroupName = Config.appGroupName
let userDefaultAthlete = "athlete"

@MainActor
class StravaLoginViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var isLoading: Bool = false
    private var authManager = AuthManager.shared
    
    var athlete: Athlete? {
        return authManager.athlete
    }
    
    func startWebOauth() {
        let session = ASWebAuthenticationSession(url: self.getStravaWebUrl(), callbackURLScheme: "memories")
        { callbackURL, error in
            self.isLoading = false
            guard let callbackURL = callbackURL else { return }
            Task {
                await self.handleOauthRedirect(url: callbackURL)
            }
        }
        
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        self.isLoading = true
        session.start()
    }
    
    func handleOauthRedirect(url: URL) async {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
              let scope = components.queryItems?.first(where: { $0.name == "scope" })?.value
        else {
            print("Invalid redirect URL")
            Analytics.capture(event: .receivedInvalidStravaOauthRedirect, eventProperties: [.cause: "invalid url"])
            return
        }
        
        guard scope.contains("activity:read_all") && scope.contains("profile:read_all")
        else {
            print("Scope restricted")
            Analytics.capture(event: .receivedInvalidStravaOauthRedirect, eventProperties: [.cause: "invalid scope"])
            return
        }
        
        Analytics.capture(event: .receivedValidStravaOauthRedirect)
        
        self.isLoading = true
        await loginWithStrava(code: code, scope: scope)
        self.isLoading = false
        
    }
    
    func loginWithStrava(code: String, scope: String) async {
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
            
            let decoded = try decoder.decode(LoginResponse.self, from: data)
            let athlete = decoded.toAthlete()
            self.authManager.login(athlete: athlete)
        } catch {
            SentrySDK.capture(error: error)
        }
    }
    
    func deleteAccount() async {
        let url = URL(string: "\(Config.backendURL)/rest/auth/delete")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.authManager.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let r = response as? HTTPURLResponse, r.statusCode == 200 {
                self.authManager.logout()
                print("succes")
            } else {
                print("error")
            }
            
        } catch {
            SentrySDK.capture(error: error)
        }
    }
    
    
    func getStravaWebUrl() -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.strava.com"
        components.path = "/oauth/mobile/authorize"
        components.queryItems = getStravaQueryItems()
        return components.url!
    }
    
    func getStravaMobileUrl() -> URL {
        var components = URLComponents()
        components.scheme = "strava"
        components.host = "oauth"
        components.path = "/mobile/authorize"
        components.queryItems = getStravaQueryItems()
        return components.url!
    }
    
    func getStravaQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "client_id", value: "106696"),
            URLQueryItem(name: "redirect_uri", value: "memories://ikigai.fyi"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "approval_prompt", value: "auto"),
            URLQueryItem(name: "scope", value: "activity:read_all,profile:read_all"),
            URLQueryItem(name: "state", value: "login"),
        ]
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func logout() {
        self.authManager.logout()
    }
    
    
    func saveAthleteToUserDefault(athlete: Athlete?) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let athleteData = try! JSONEncoder().encode(athlete)
            userDefaults.set(athleteData, forKey: userDefaultAthlete)
        }
    }
}

struct LoginResponse: Codable {
    struct LoginAthlete: Codable {
        let uuid: String
        let email: String?
        let firstName: String
        let lastName: String
        let pictureUrl: String
    }
    
    let athlete: LoginAthlete
    let jwt: String
    
    func toAthlete() -> Athlete {
        return Athlete(
            uuid: self.athlete.uuid,
            email: self.athlete.email,
            firstName: self.athlete.firstName,
            lastName: self.athlete.lastName,
            pictureUrl: self.athlete.pictureUrl,
            jwt: self.jwt
        )
    }
}
