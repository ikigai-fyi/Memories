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
        apiKey: "a559a5b51a65fe2a19fefa2811ff7862",
        serverZone: ServerZone.EU
    )
)

let identify = Identify()

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

