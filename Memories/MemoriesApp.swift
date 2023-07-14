//
//  MemoriesApp.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI
import Activity
import Sentry
import AmplitudeSwift
import PostHog

@main
struct MemoriesApp: App {
    @StateObject var loginViewModel = StravaLoginViewModel()
    @StateObject var activityViewModel = ActivityViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        SentrySDK.start { options in
            options.dsn = "https://2307db5e8e854158be765b26bce256ed@o4505126569246720.ingest.sentry.io/4505248857784320"
            options.debug = false
            options.environment = Config.env
        }
        
        Analytics.initPostHog()
    }
    
    var body: some Scene {
        WindowGroup {
            if loginViewModel.athlete == nil {
                StravaLoginView().environmentObject(loginViewModel)
            } else {
                MemoriesHomeView().environmentObject(loginViewModel).environmentObject(activityViewModel)
            }
        }.onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                //posthog
                if let athlete = self.loginViewModel.athlete {
                    PHGPostHog.shared()?.identify(athlete.uuid)
                }
                
                // amplitude
                Amplitude.instance.setUserId(userId: self.loginViewModel.athlete?.uuid)
                Amplitude.instance.track(eventType: AnalyticsEvents.openApp)
                
                // Force flush to
                Amplitude.instance.flush()
            default: ()
            }
        }
    }
}
