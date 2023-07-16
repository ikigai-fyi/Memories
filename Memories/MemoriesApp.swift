//
//  MemoriesApp.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI
import Activity
import Sentry
import Crisp

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
        
        Analytics.initialize()
        
        CrispSDK.configure(websiteID: "ddfdd35f-d323-4ca9-8df6-c0380e53ad72")
        if let athlete = StravaLoginViewModel.getAthleteFromUserDefault() {
            CrispSDK.user.nickname = athlete.fullName
            CrispSDK.user.avatar = URL(string: athlete.pictureUrl)
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
                if let athlete = StravaLoginViewModel.getAthleteFromUserDefault() {
                    Analytics.identify(athlete: athlete)
                }
                
                Analytics.capture(event: .appActive, userProperties: [.lastSeenDate: Date().ISO8601Format()])
            default: ()
            }
        }
    }
    
    private func shouldAskForRating() {
//        let widgetConf = WidgetCenter.shared.getCurrentConfigurations
//        let widgetActive = widgetConf.
        
        // Keep track of the most recent app version that prompts the user for a review.
//        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
//
//
//        // Get the current bundle version for the app.
//        let infoDictionaryKey = kCFBundleVersionKey as String
//        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
//            else { fatalError("Expected to find a bundle version in the info dictionary.") }
//         // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
//         if count >= 4 && currentVersion != lastVersionPromptedForReview {
//             Task { @MainActor [weak self] in
//                 // Delay for two seconds to avoid interrupting the person using the app.
//                 // Use the equation n * 10^9 to convert seconds to nanoseconds.
//                 try? await Task.sleep(nanoseconds: UInt64(2e9))
//                 if let windowScene = self?.view.window?.windowScene,
//                    self?.navigationController?.topViewController is ProcessCompletedViewController {
//                     SKStoreReviewController.requestReview(in: windowScene)
//                     UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
//                }
//             }
//         }
//
    }
}
