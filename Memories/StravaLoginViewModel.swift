//
//  StravaLoginViewModel.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import Foundation
import AuthenticationServices

class StravaLoginViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    func launchOauthFlow() {
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
                            self.handleOauthRedirect(url: url)
                        }
                    }
            
            authSession.presentationContextProvider = self
            authSession.start()
        }
    }
    
    func handleOauthRedirect(url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let code = components.queryItems?.first(where: { $0.name == "code" }),
           let scope = components.queryItems?.first(where: { $0.name == "scope" })
        {
            // TODO: send code and scope to backend to create and login athlete
            print(code)
            print(scope)
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
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
