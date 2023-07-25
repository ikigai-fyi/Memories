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
import Sentry

struct Provider: TimelineProvider {
    private let viewModel = ActivityViewModel()
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date())
    }

    @MainActor func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let loggedIn = StravaLoginViewModel.isLoggedIn()
        let activity = ActivityViewModel.getActivityFromUserDefault()
        let error = ActivityViewModel.getErrorFromUserDefault()
        completion(SimpleEntry(date: Date(), activity: activity, error: error))
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        self.initializeDependencies()
        self.onGetTimeline()
        
        // Home screen was forced refresh, update the widget with user defaults only
        if ActivityViewModel.getUnseenWidgetForceRefreshFromUserDefault() {
            let activity = ActivityViewModel.getActivityFromUserDefault()
            let error = ActivityViewModel.getErrorFromUserDefault()
            viewModel.forceRefreshWidgetProcessed()
            completion(buildTimeline(activity: activity, error: error))
        } else {
            Task {
                await viewModel.fetchAndStoreRandomActivity()
                completion(buildTimeline(activity: viewModel.activity, error: viewModel.error))
            }
        }
    }
    
    @MainActor private func buildTimeline(activity: Activity?, error: ActivityError?) -> Timeline<SimpleEntry> {
        let entries = [SimpleEntry(date: Date(), activity: activity, error: error)]
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date())!
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
    
    @MainActor private func onGetTimeline() {
        if let athlete = StravaLoginViewModel.getAthleteFromUserDefault() {
            Analytics.identify(athlete: athlete)
        }
        
        Analytics.capture(event: .systemUpdateWidget)
    }
    
    @MainActor private func initializeDependencies() {
        // We don't really know where to do that for widgets, so we do it for every timeline refresh, as it's pretty rare
        SentrySDK.start { options in
            options.dsn = "https://2307db5e8e854158be765b26bce256ed@o4505126569246720.ingest.sentry.io/4505248857784320"
            options.debug = false
            options.environment = Config.env
        }
        
        Analytics.initialize()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let activity: Activity?
    let error: ActivityError?
    
    init(date: Date, activity: Activity? = nil, error: ActivityError? = nil) {
        self.date = date
        self.activity = activity
        self.error = error
    }
}

struct MemoriesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        MemoriesWidgetView(activity: entry.activity, error: entry.error)
    }
}

struct MemoriesWidget: Widget {
    let kind: String = "MemoriesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MemoriesWidgetEntryView(entry: entry)
        }
        .contentMarginsDisabled() // Warning iOS 17 StandBy
    }
}

struct MemoriesWidget_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
