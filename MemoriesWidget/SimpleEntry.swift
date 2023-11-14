//
//  SimpleEntry.swift
//  Memories
//
//  Created by Paul Nicolet on 14/11/2023.
//

import Foundation
import WidgetKit
import Activity
import SwiftUI

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
    var entry: SimpleEntry

    var body: some View {
        MemoriesWidgetView(activity: entry.activity, error: entry.error)
    }
}
