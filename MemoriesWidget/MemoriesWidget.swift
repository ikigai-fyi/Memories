//
//  MemoriesWidget.swift
//  MemoriesWidget
//
//  Created by Vincent Ballet on 06/05/2023.
//

import WidgetKit
import SwiftUI

struct MemoriesWidget: Widget {
    let kind: String = "MemoriesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClassicTimelineProvider()) { entry in
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
