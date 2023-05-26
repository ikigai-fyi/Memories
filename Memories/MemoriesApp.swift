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
                self.onNewSession()
            default: ()
            }
        }
    }
    
    func onNewSession() {
        // FIXME Amplitude is supposed to have it's own session mechanism?
        // https://www.docs.developers.amplitude.com/data/sdks/ios-swift/#user-sessions
        let identify = Identify()
        let now = DateFormatter.standard.string(from: Date())
        identify.set(property: AnalyticsProperties.lastSeenDate, value: now)
        identify.append(property: AnalyticsProperties.numTotalSessions, value: 1)
        amplitude.identify(identify: identify)
    }
}
