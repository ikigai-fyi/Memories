//
//  StravaLoginViewModel.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import Foundation
import AuthenticationServices
import WidgetKit
import AmplitudeSwift

let userDefaultAthlete = "athlete"
let userDefaultJwt = "jwt"

@MainActor
public class StravaLoginViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published public var athlete: Athlete? = getAthleteFromUserDefault()
    @Published public var jwt: String? = getJwtFromUserDefault()
    
    public func launchOauthFlow() {
        let appUrl = getStravaMobileUrl()
        let webUrl = getStravaWebUrl()

        if UIApplication.shared.canOpenURL(appUrl) {
            // Open Strava app if installed, if will be redirected to our app through a deeplink
            UIApplication.shared.open(appUrl, options: [:])
        } else {
            // If Strava app is not installed, manage oauth through a webview
            let authSession = ASWebAuthenticationSession(
                url: webUrl, callbackURLScheme:
                    "memories") { (url, error) in
                        if let error = error {
                            print(error)
                        } else if let url = url {
                            Task {
                                await self.handleOauthRedirect(url: url)
                            }
                        }
                    }

            authSession.presentationContextProvider = self
            authSession.start()
        }
    }
    
    public func handleOauthRedirect(url: URL) async {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let code = components.queryItems?.first(where: { $0.name == "code" }),
           let scope = components.queryItems?.first(where: { $0.name == "scope" })
        {
            await loginWithStrava(code: code.value!, scope: scope.value!)
        }
    }
    
    public func loginWithStrava(code: String, scope: String) async {
        let url = URL(string: "https://api-dev.ikigai.fyi/rest/auth/login/strava")!
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
            saveAthleteToUserDefault(athlete: decoded.athlete)
            self.athlete = decoded.athlete
            saveJwtToUserDefault(jwt: decoded.jwt)
            self.jwt = decoded.jwt
                
            // analytics
            let identify = Identify()
            let uuid = athlete!.uuid
            let now = DateFormatter.standard.string(from: Date())
            identify.setOnce(property: AnalyticsProperties.userId, value: uuid)
            identify.setOnce(property: AnalyticsProperties.signupDate, value: now)
            amplitude.identify(identify: identify)
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
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    static func getAthleteFromUserDefault() -> Athlete? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultAthlete) {
                return try! JSONDecoder().decode(Athlete.self, from: data)
            }
        }
        
        return nil
    }
    
    func saveAthleteToUserDefault(athlete: Athlete) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let athleteData = try! JSONEncoder().encode(athlete)
            userDefaults.set(athleteData, forKey: userDefaultAthlete)
        }
    }
    
    static func getJwtFromUserDefault() -> String? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultJwt) {
                return try! JSONDecoder().decode(String.self, from: data)
            }
        }
        
        return nil
    }
    
    func saveJwtToUserDefault(jwt: String) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let jwtData = try! JSONEncoder().encode(jwt)
            userDefaults.set(jwtData, forKey: userDefaultJwt)
        }
    }
}

public struct LoginResponse: Codable {
    public let athlete: Athlete
    public let jwt: String
}
