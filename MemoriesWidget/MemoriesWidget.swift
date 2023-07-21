//
//  MemoriesWidget.swift
//  MemoriesWidget
//
//  Created by Vincent Ballet on 06/05/2023.
//

import WidgetKit
import SwiftUI
import Activity
import PostHog

struct Provider: TimelineProvider {
    private let viewModel = ActivityViewModel()
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date())
    }

    @MainActor func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let loggedIn = StravaLoginViewModel.isLoggedIn()
        let activity = ActivityViewModel.getActivityFromUserDefault()
        completion(SimpleEntry(date: Date(), loggedIn: loggedIn, activity: activity))
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        self.onGetTimeline()
        
        let isLoggedIn = StravaLoginViewModel.isLoggedIn()
        
        // Home screen was forced refresh, update the widget with user defaults only
        if ActivityViewModel.getUnseenWidgetForceRefreshFromUserDefault() {
            let activity = ActivityViewModel.getActivityFromUserDefault()
            viewModel.forceRefreshWidgetProcessed()
            completion(buildTimeline(loggedIn: isLoggedIn, activity: activity))
        } else {
            Task {
                await viewModel.fetchAndStoreRandomActivity()
                completion(buildTimeline(loggedIn: isLoggedIn, activity: viewModel.activity))
            }
        }
    }
    
    @MainActor private func buildTimeline(loggedIn: Bool, activity: Activity?) -> Timeline<SimpleEntry> {
        let entries = [SimpleEntry(date: Date(), loggedIn: loggedIn, activity: activity)]
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
    
    @MainActor private func onGetTimeline() {
        Analytics.initialize()
        if let athlete = StravaLoginViewModel.getAthleteFromUserDefault() {
            Analytics.identify(athlete: athlete)
        }
        
        Analytics.capture(event: .systemUpdateWidget)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let loggedIn: Bool
    let activity: Activity?
    
    init(date: Date, loggedIn: Bool = false,  activity: Activity? = nil) {
        self.date = date
        self.loggedIn = loggedIn
        self.activity = activity
    }
}

struct MemoriesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        MemoriesWidgetView(loggedIn: entry.loggedIn, activity: entry.activity)
    }
}

struct MemoriesWidget: Widget {
    let kind: String = "MemoriesWidget"

// Note : does not work. Seems not to be executed before buildTimeline() is triggered
//    init() {
//        Analytics.initPostHog()
//    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MemoriesWidgetEntryView(entry: entry)
        }
    }
}

struct MemoriesWidget_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
