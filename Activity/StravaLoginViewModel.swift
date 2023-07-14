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

let userDefaultAthlete = "athlete"

@MainActor
public class StravaLoginViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published public var isLoading: Bool = false
    @Published public var athlete: Athlete? = getAthleteFromUserDefault()
    
    public func startWebOauth() {
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

    public func handleOauthRedirect(url: URL) async {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let code = components.queryItems?.first(where: { $0.name == "code" }),
           let scope = components.queryItems?.first(where: { $0.name == "scope" })
        {
            self.isLoading = true
            await loginWithStrava(code: code.value!, scope: scope.value!)
            self.isLoading = false
        }
    }
    
    public func loginWithStrava(code: String, scope: String) async {
        if !(scope.contains("activity:read_all") && scope.contains("profile:read_all")) {
            print("Scope restricted, error to handle")
            return
        }
        
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
            self.athlete = athlete
            self.saveAthleteToUserDefault(athlete: athlete)
            
            // analytics - posthog
            if let athlete = self.athlete{
                PHGPostHog.shared()?.identify(athlete.uuid, properties:[
                    AnalyticsProperties.firstName: athlete.firstName,
                    AnalyticsProperties.lastName: athlete.lastName
                ])
            }
            
            
        } catch {
            print(error)
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
    
    public func getStravaMobileUrl() -> URL {
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
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    public static func getAthleteFromUserDefault() -> Athlete? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultAthlete) {
                return try? JSONDecoder().decode(Athlete.self, from: data)
            }
        }
        
        return nil
    }
    
    public static func getActivityFromUserDefault() -> Activity? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultActivity) {
                return try? JSONDecoder().decode(Activity.self, from: data)
            }
        }
        
        return nil
    }
    
    public static func isLoggedIn() -> Bool {
        return !(self.getAthleteFromUserDefault() == nil)
    }
    
    public static func athleteIdIfLoggedIn() -> String? {
        return self.getAthleteFromUserDefault()?.uuid
    }
    
    public func logout() {
        self.athlete = nil
        self.saveAthleteToUserDefault(athlete: nil)
        
        // analytics
        PHGPostHog.shared()?.reset()
        
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
        let firstName: String
        let lastName: String
        let pictureUrl: String
    }
    
    let athlete: LoginAthlete
    let jwt: String
    
    func toAthlete() -> Athlete {
        return Athlete(uuid: self.athlete.uuid, firstName: self.athlete.firstName, lastName: self.athlete.lastName, pictureUrl: self.athlete.pictureUrl, jwt: self.jwt)
    }
}
