//
//  Analytics.swift
//  Memories
//
//  Created by Vincent Ballet on 06/05/2023.
//

import Foundation
import AmplitudeSwift

let amplitude = Amplitude(
    configuration: Configuration(
        apiKey: Config.amplitudeApiKey,
        serverZone: ServerZone.EU,
    )
)

struct AnalyticsEvents {
    static let connectStrava = "connectStrava"
    static let addWidgetHelp = "addWidgetHelp"
    static let refreshActivities = "refreshActivities"
    static let addWidget = "addWidget"
    static let openApp = "openApp"
    static let removeWidget = "removeWidget"
}
    
struct AnalyticsProperties {
    static let userId = "userId"
    static let size = "size"
    static let activeWidget = "activeWidget"
    static let addedWidgets = "addedWidgets"
    static let signupDate = "signupDate"
    static let appInstallDate = "appInstallDate"
    static let numTotalSessions = "numTotalSessions"
    static let lastSeenDate = "lastSeenDate"
}

