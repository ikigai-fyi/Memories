//
//  Analytics.swift
//  Memories
//
//  Created by Vincent Ballet on 06/05/2023.
//

import Foundation
import PostHog

struct Analytics {
    static func initialize() {
        let configuration = PHGPostHogConfiguration(apiKey: Config.postHogApiKey, host: "https://eu.posthog.com")
        configuration.captureApplicationLifecycleEvents = true
        configuration.recordScreenViews = false
        configuration.flushAt = 1
        PHGPostHog.setup(with: configuration)
    }
    
    static func identify(athlete: Athlete) {
        var props = [
            Property.firstName.rawValue: athlete.firstName,
            Property.lastName.rawValue: athlete.lastName
        ]
        if let email = athlete.email {
            props[Property.email.rawValue] = email
        }
        
        PHGPostHog.shared()?.identify(athlete.uuid, properties: props)
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
        case viewSettingsScreen
        case viewShareScreen
        
        // actions
        case connectStrava
        case receivedValidStravaOauthRedirect
        case receivedInvalidStravaOauthRedirect
        case addWidgetHelp
        case refreshActivities
        case shareFeedback
        case shareToFriends
        case loginHelpButtonClicked
        case logout
        case deleteAccount
        case confirmDeleteAccount
        case goToHomeScreenAfterHelpVideo
        case openActivityOnStrava
        case updateSettingMeasurementSystem
        case updateSettingRefreshRatePerDay
        case shareMemory

        // lifecycle
        case appActive
        case systemFetchedRandomActivity
        case systemUpdateWidget
        case systemAskForReview
    }
        
    enum Property: String {
        // user attributes
        case firstName
        case lastName
        case email
        case lastSeenDate
        case lastActivityFetchState
        case measurementSystem
        case refreshRatePerDay

        //action attributes
        case from
        case abTestGroup
        case cause
        case with
        case settingValue
    }
}
