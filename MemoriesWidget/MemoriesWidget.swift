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

struct MemoriesWidget: Widget {
    let kind: String = "MemoriesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MemoryTimelineProvider()) { entry in
            MemoriesWidgetView(memory: entry.memory, error: entry.error, withBadges: true, isInWidget: true)
        }
        .contentMarginsDisabled()
    }
}

struct MemoriesWidget_Previews: PreviewProvider {
    static var previews: some View {
        let entry = MemoryTimelineEntry(date: Date())
        MemoriesWidgetView(memory: entry.memory, error: entry.error, withBadges: true, isInWidget: true)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
