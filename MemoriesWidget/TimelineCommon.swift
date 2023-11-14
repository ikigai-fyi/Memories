//
//  TimelineCommon.swift
//  Memories
//
//  Created by Paul Nicolet on 14/11/2023.
//

import Foundation
import Activity
import WidgetKit
import Sentry

struct TimelineCommon {
    public func buildTimeline(activity: Activity?, error: ActivityError?) -> Timeline<SimpleEntry> {
        let entries = [SimpleEntry(date: Date(), activity: activity, error: error)]
        let refreshRate = Int(24 / Helper.getUserWidgetRefreshRatePerDay()!)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: refreshRate, to: Date())!
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
    
    @MainActor public func onGetTimeline() {
        if let athlete = StravaLoginViewModel.getAthleteFromUserDefault() {
            Analytics.identify(athlete: athlete)
        }
        
        Analytics.capture(event: .systemUpdateWidget)
    }
    
    public func initializeDependencies() {
        // We don't really know where to do that for widgets, so we do it for every timeline refresh, as it's pretty rare
        SentrySDK.start { options in
            options.dsn = "https://2307db5e8e854158be765b26bce256ed@o4505126569246720.ingest.sentry.io/4505248857784320"
            options.debug = false
            options.environment = Config.env
        }
        
        Analytics.initialize()
    }
}
