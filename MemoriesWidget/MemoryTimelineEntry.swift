//
//  MemoryTimelineEntry.swift
//  MemoriesWidgetExtension
//
//  Created by Paul Nicolet on 26/11/2023.
//

import Foundation
import WidgetKit

struct MemoryTimelineEntry: TimelineEntry {
    let date: Date
    let memory: Memory?
    let error: ActivityError?
    
    init(date: Date, memory: Memory? = nil, error: ActivityError? = nil) {
        self.date = date
        self.memory = memory
        self.error = error
    }
}
