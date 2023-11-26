//
//  MemoriesWidget.swift
//  MemoriesWidget
//
//  Created by Vincent Ballet on 06/05/2023.
//

import WidgetKit
import SwiftUI
import PostHog
import Sentry

struct Provider: TimelineProvider {
    private let viewModel = ActivityViewModel()
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date())
    }

    @MainActor func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            await viewModel.fetchMemory()
            let entry = SimpleEntry(date: Date(), memory: viewModel.memory, error: viewModel.error)
            completion(entry)
        }
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        self.initializeDependencies()
        self.onGetTimeline()
        
        Task {
            await viewModel.fetchMemory()
            let entries = [SimpleEntry(date: Date(), memory: viewModel.memory, error: viewModel.error)]
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            completion(Timeline(entries: entries, policy: .after(nextUpdate)))
        }
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
    let memory: Memory?
    let error: ActivityError?
    
    init(date: Date, memory: Memory? = nil, error: ActivityError? = nil) {
        self.date = date
        self.memory = memory
        self.error = error
    }
}

struct MemoriesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        MemoriesWidgetView(memory: entry.memory, error: entry.error, withBadges: true, isInWidget: true)
    }
}

struct MemoriesWidget: Widget {
    let kind: String = "MemoriesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MemoriesWidgetEntryView(entry: entry)
        }
        .contentMarginsDisabled()
    }
}

struct MemoriesWidget_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
