//
//  Analytics.swift
//  Memories
//
//  Created by Vincent Ballet on 06/05/2023.
//

import Foundation
import PostHog
import Activity

struct Analytics {
    static func initialize() {
        let configuration = PHGPostHogConfiguration(apiKey: Config.postHogApiKey, host: "https://eu.posthog.com")
        configuration.captureApplicationLifecycleEvents = true
        configuration.recordScreenViews = true
        configuration.flushAt = 1
        PHGPostHog.setup(with: configuration)
    }
    
    static func identify(athlete: Athlete) {
        PHGPostHog.shared()?.identify(athlete.uuid, properties: [
            Property.firstName.rawValue: athlete.firstName,
            Property.lastName.rawValue: athlete.lastName,
        ])
    }
    
    static func reset() {
        PHGPostHog.shared()?.reset()
    }
    
    static func capture(event: Event, eventProperties: [Property: Any] = [:], userProperties: [Property: Any] = [:]) {
        var properties = eventProperties.reduce(into: [:]) { result, item in
            result[item.key.rawValue] = item.value
        }
        
        if !userProperties.isEmpty {
            properties["$set"] = userProperties.reduce(into: [:]) { result, item in
                result[item.key.rawValue] = item.value
            }
        }
        
        PHGPostHog.shared()?.capture(event.rawValue, properties: properties)
    }
    
    
    enum Event: String {
        // screens
        case viewLoginScreen
        case viewHomeScreen
        
        // actions
        case connectStrava
        case addWidgetHelp
        case refreshActivities
        case shareFeedback
        case shareToFriends
        case loginHelpButtonClicked
        case logout
        case deleteAccount
        case confirmDeleteAccount

        // lifecycle
        case appActive
        case systemUpdateWidget
        case systemAskForReview
    }
        
    enum Property: String {
        // user attributes
        case firstName
        case lastName
        case lastSeenDate
        
        //action attributes
        case from
        case abTestGroup
    }
}
