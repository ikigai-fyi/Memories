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

@MainActor
public class StravaLoginViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published public var isLoading: Bool = false
    @Published public var athlete: Athlete? = getAthleteFromUserDefault()
    
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
                
            // analytics
            Amplitude.instance.setUserId(userId: athlete.uuid)
            let now = DateFormatter.standard.string(from: Date())
            let identify = Identify().setOnce(property: AnalyticsProperties.signupDate, value: now)
            Amplitude.instance.identify(identify: identify)
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
    
    func saveAthleteToUserDefault(athlete: Athlete) {
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
