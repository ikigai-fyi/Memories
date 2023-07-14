//
//  Analytics.swift
//  Memories
//
//  Created by Vincent Ballet on 06/05/2023.
//

import Foundation
import AmplitudeSwift

extension Amplitude {
    static var instance = Amplitude(
        configuration: Configuration(
            apiKey: Config.amplitudeApiKey,
            logLevel: LogLevelEnum.DEBUG,
            callback: { (event: BaseEvent, code: Int, message: String) -> Void in
                print("eventcallback: \(event), code: \(code), message: \(message)")
            },
            serverZone: ServerZone.EU,
            flushEventsOnClose: true,
            minTimeBetweenSessionsMillis: 15000
        )
    )
}

struct AnalyticsEvents {
    static let connectStrava = "connectStrava"
    static let addWidgetHelp = "addWidgetHelp"
    static let refreshActivities = "refreshActivities"
    static let addWidget = "addWidget"
    static let openApp = "openApp"
    static let removeWidget = "removeWidget"
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
