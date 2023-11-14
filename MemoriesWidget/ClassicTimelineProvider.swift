//
//  ClassicTimelineProvider.swift
//  Memories
//
//  Created by Paul Nicolet on 14/11/2023.
//

import Foundation
import WidgetKit
import SwiftUI
import Activity

struct ClassicTimelineProvider: TimelineProvider {
    private let common = TimelineCommon()
    private let viewModel = ActivityViewModel()
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date())
    }

    @MainActor func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let activity = ActivityViewModel.getActivityFromUserDefault()
        let error = ActivityViewModel.getErrorFromUserDefault()
        completion(SimpleEntry(date: Date(), activity: activity, error: error))
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        self.common.initializeDependencies()
        self.common.onGetTimeline()
        
        // Home screen was forced refresh, update the widget with user defaults only
        if ActivityViewModel.getUnseenWidgetForceRefreshFromUserDefault() {
            let activity = ActivityViewModel.getActivityFromUserDefault()
            let error = ActivityViewModel.getErrorFromUserDefault()
            viewModel.forceRefreshWidgetProcessed()
            completion(self.common.buildTimeline(activity: activity, error: error))
        } else {
            Task {
                await viewModel.fetchRandomActivity()
                completion(self.common.buildTimeline(activity: viewModel.activity, error: viewModel.error))
            }
        }
    }
}
