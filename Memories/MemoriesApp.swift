//
//  MemoriesApp.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI
import Sentry
import Crisp
import PostHog

@main
struct MemoriesApp: App {
    @StateObject var loginViewModel = StravaLoginViewModel()
    @StateObject var memoryViewModel = MemoryViewModel()
    @StateObject var screenManager = ScreenManager.shared
    @Environment(\.scenePhase) var scenePhase

    
    init() {
        SentrySDK.start { options in
            options.dsn = "https://2307db5e8e854158be765b26bce256ed@o4505126569246720.ingest.sentry.io/4505248857784320"
            options.debug = false
            options.environment = Config.env
        }
        
        Analytics.initialize()
        
        CrispSDK.configure(websiteID: "ddfdd35f-d323-4ca9-8df6-c0380e53ad72")
        if let athlete = AuthManager.shared.athlete {
            CrispSDK.user.nickname = athlete.fullName
            CrispSDK.user.avatar = URL(string: athlete.pictureUrl)
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            switch screenManager.screen {
            case .login:
                StravaLoginView {
                    let next: ScreenManager.Screen = AuthManager.shared.athlete!.hasEmail ? .home : .email
                    self.screenManager.goTo(screen: next)
                }.environmentObject(loginViewModel)
            case .email:
                EmailFormView {
                    self.screenManager.goTo(screen: .home)
                }
            case .home:
                MemoriesHomeView().environmentObject(loginViewModel).environmentObject(memoryViewModel)
            }
        }.onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                if let athlete = AuthManager.shared.athlete {
                    Analytics.identify(athlete: athlete)
                }
                
                Analytics.capture(event: .appActive, userProperties: [.lastSeenDate: Date().ISO8601Format()])
            default: ()
            }
        }
    }
    
}
