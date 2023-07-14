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
    
    static func capture(event: Event) {
        PHGPostHog.shared()?.capture(event.rawValue)
    }
    
    
    enum Event: String {
        // screens
        case viewLoginScreen
        
        // actions
        case connectStrava
        case addWidgetHelp
        case refreshActivities
        
        // lifecycle
        case systemUpdateWidget
    }
        
    enum Property: String {
        case firstName
        case lastName
    }
}
