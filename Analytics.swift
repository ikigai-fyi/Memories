//
//  Analytics.swift
//  Memories
//
//  Created by Vincent Ballet on 06/05/2023.
//

import Foundation
import PostHog

struct Analytics {
    static func initPostHog(){
        let configuration = PHGPostHogConfiguration(apiKey: Config.postHogApiKey, host: "https://eu.posthog.com")
        configuration.captureApplicationLifecycleEvents = true
        configuration.recordScreenViews = true
        PHGPostHog.setup(with: configuration)
    }
}

struct AnalyticsEvents {
    // screens
    static let viewLoginScreen = "viewLoginScreen"
    
    // actions
    static let connectStrava = "connectStrava"
    static let addWidgetHelp = "addWidgetHelp"
    static let refreshActivities = "refreshActivities"
    static let addWidget = "addWidget"
    static let openApp = "openApp"
    static let removeWidget = "removeWidget"
    
    // lifecycle
    static let systemUpdateWidget = "systemUpdateWidget"
}
    
struct AnalyticsProperties {
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let size = "size"
    static let activeWidget = "activeWidget"
    static let addedWidgets = "addedWidgets"
    static let signupDate = "signupDate"
    static let appInstallDate = "appInstallDate"
}
