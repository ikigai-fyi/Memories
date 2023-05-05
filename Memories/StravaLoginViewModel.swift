//
//  StravaLoginViewModel.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import Foundation
import AuthenticationServices

class StravaLoginViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func signIn() {
        let appUrl = URL(string: "strava://oauth/mobile/authorize?client_id=106696&redirect_uri=memories%3A%2F%2Flocalhost&response_type=code&approval_prompt=auto&scope=activity%3Aread_all%2Cprofile%3Aread_all&state=test")
        
        let webUrl = URL(string: "https://www.strava.com/oauth/mobile/authorize?client_id=106696&redirect_uri=memories%3A%2F%2Flocalhost&response_type=code&approval_prompt=auto&scope=activity%3Aread_all%2Cprofile%3Aread_all&state=test")
        
        if UIApplication.shared.canOpenURL(appUrl!) {
            UIApplication.shared.open(appUrl!, options: [:])
        } else {
            let authSession = ASWebAuthenticationSession(
                url: webUrl!, callbackURLScheme:
                    "memories") { (url, error) in
                        if let error = error {
                            print(error)
                        } else if let url = url {
                            self.handleSignedIn(url: url)
                        }
                    }
            
            authSession.presentationContextProvider = self
            authSession.start()
        }
    }
    
    func handleSignedIn(url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let code = components.queryItems?.first(where: { $0.name == "code" }),
           let scope = components.queryItems?.first(where: { $0.name == "scope" })
        {
            print(code)
            print(scope)
        }
    }
}
