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
    
    // lifecycle
    static let systemUpdateWidget = "systemUpdateWidget"
}
    
struct AnalyticsProperties {
    static let firstName = "firstName"
    static let lastName = "lastName"
}
