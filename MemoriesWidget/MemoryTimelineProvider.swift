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
    private let memoryService = MemoryService()
    
    func placeholder(in context: Context) -> MemoryTimelineEntry {
        return .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (MemoryTimelineEntry) -> ()) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            Task {
                await self.initializeDependencies()
                await self.onGetTimeline()
                
                let (memory, error) = await self.fetchMemory()
                let entry = MemoryTimelineEntry(date: Date(), memory: memory, error: error)
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MemoryTimelineEntry>) -> ()) {
        Task {
            await self.initializeDependencies()
            await self.onGetTimeline()
            let (memory, error) = await self.fetchMemory()
            let entries = [MemoryTimelineEntry(date: Date(), memory: memory, error: error)]
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            completion(Timeline(entries: entries, policy: .after(nextUpdate)))
        }
    }
    
    private func fetchMemory() async -> (Memory?, ActivityError?) {
        do {
            return ((try await memoryService.fetch()), nil)
        } catch let e as ActivityError {
            return (nil, e)
        } catch {
            return (nil, .other)
        }
    }

    @MainActor private func onGetTimeline() {
        if let athlete = AuthManager.shared.athlete {
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
