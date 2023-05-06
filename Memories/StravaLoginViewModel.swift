//
//  StravaLoginViewModel.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import Foundation
import AuthenticationServices
import WidgetKit

// Used MainActor to make sure things happen on the main thread
// To be honest no clue what I'm doing, it's just that some article said to do that
// Because you can't assign @Published variables from background thread with async / wait
// There is probably a better way, to dig
@MainActor
class StravaLoginViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var firstName = "Not logged in"
    @Published var lastName = "Not logged in"
    @Published var pictureUrl = "Not logged in"
    
    func launchOauthFlow() {
        amplitude.track(eventType: "Button Clicked", eventProperties: ["action": "stravaLogin"])
        
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
    
    func handleOauthRedirect(url: URL) async {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let code = components.queryItems?.first(where: { $0.name == "code" }),
           let scope = components.queryItems?.first(where: { $0.name == "scope" })
        {
            await loginWithStrava(code: code.value!, scope: scope.value!)
        }
    }
    
    func loginWithStrava(code: String, scope: String) async {
        let url = URL(string: "https://sh577q4d5c.execute-api.eu-west-1.amazonaws.com/dev/rest/auth/login/strava")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json = ["code": code, "scope": scope]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print(String(decoding: data, as: UTF8.self))
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any?]
                let athlete = json["athlete"] as! [String: Any?]
                self.firstName = athlete["first_name"] as! String
                self.lastName = athlete["last_name"] as! String
                self.pictureUrl = athlete["picture_url"] as! String
                saveIntoUserDefaults()
                
            } catch {
                print(error)
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
            URLQueryItem(name: "redirect_uri", value: "memories://localhost"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "approval_prompt", value: "auto"),
            URLQueryItem(name: "scope", value: "activity:read_all,profile:read_all"),
            URLQueryItem(name: "state", value: "login"),
        ]
    }
    
    private func saveIntoUserDefaults() {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            
            let data = try! JSONEncoder().encode(pictureUrl)
            userDefaults.set(data, forKey: userDefaultsActivityPictureUrl)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
