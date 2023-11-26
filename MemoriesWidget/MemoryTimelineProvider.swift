//
//  MemoryTimelineProvider.swift
//  MemoriesWidgetExtension
//
//  Created by Paul Nicolet on 26/11/2023.
//

import Foundation
import WidgetKit
import Sentry

struct MemoryTimelineProvider: TimelineProvider {
    private let viewModel = MemoryViewModel()
    
    func placeholder(in context: Context) -> MemoryTimelineEntry {
        return MemoryTimelineEntry(date: Date())
    }

    @MainActor func getSnapshot(in context: Context, completion: @escaping (MemoryTimelineEntry) -> ()) {
        Task {
            await viewModel.fetchMemory()
            let entry = MemoryTimelineEntry(date: Date(), memory: viewModel.memory, error: viewModel.error)
            completion(entry)
        }
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<MemoryTimelineEntry>) -> ()) {
        self.initializeDependencies()
        self.onGetTimeline()
        
        Task {
            await viewModel.fetchMemory()
            let entries = [MemoryTimelineEntry(date: Date(), memory: viewModel.memory, error: viewModel.error)]
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
