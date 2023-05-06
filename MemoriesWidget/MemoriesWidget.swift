//
//  MemoriesWidget.swift
//  MemoriesWidget
//
//  Created by Vincent Ballet on 06/05/2023.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        
        let pictureUrl = Helper.getPictureUrlFromUserDefault()

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, url: URL(string: pictureUrl))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let url: URL?
    
    init(date: Date, url: URL? = nil) {
        self.date = date
        self.url = url
    }
}

struct MemoriesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        MemoriesWidgetView(url: entry.url)
    }
}

struct MemoriesWidget: Widget {
    let kind: String = "MemoriesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MemoriesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct MemoriesWidget_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
