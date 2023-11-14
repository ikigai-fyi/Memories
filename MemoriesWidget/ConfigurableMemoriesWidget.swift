//
//  MemoriesWidget.swift
//  MemoriesWidget
//
//  Created by Vincent Ballet on 06/05/2023.
//

import WidgetKit
import SwiftUI

@available(iOS 17.0, *)
struct ConfigurableMemoriesWidget: Widget {
    let kind: String = "ConfigurableMemoriesWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: MemoriesWidgetConfigurationIntent.self, provider: ConfigurationTimelineProvider()) { entry in
            MemoriesWidgetEntryView(entry: entry)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("MyText Widget")
        .description("Show you favorite text!")
    }
}

struct ConfigurableMemoriesWidget_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
