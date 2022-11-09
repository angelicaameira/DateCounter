//
//  Widgets.swift
//  Widgets
//
//  Created by Antonio Germano on 08/11/22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    //let title: String
    let date: Date
    let configuration: ConfigurationIntent
}

struct WidgetsEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            defaultView
        case .systemMedium:
            defaultView
        case .systemLarge:
            defaultView
        case .systemExtraLarge:
            defaultView
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(alignment: .center) {
                    Text("Font title here")
                    Text("Font title here")
                    Text("Font title here")
                    Text(entry.date, style: .relative)
                }
                .font(.footnote)
            }
        case .accessoryRectangular:
            accessoryRectangular
        case .accessoryInline:
            accessoryInline
        @unknown default:
            defaultView
        }
    }
    
    var defaultView: some View {
        return VStack {
            Text("Event title")
            Text(entry.date, style: .time)
        }
    }
    
    var accessoryInline: some View {
        VStack {
            Text("(8h) Event title")
        }
    }
    
    var accessoryRectangular: some View {
        VStack(alignment: .leading) {
            Text("Event title")
                .foregroundColor(.primary)
                .bold()
            Text("Event description")
                .foregroundColor(.secondary)
                .font(.footnote)
            Text(entry.date, style: .relative)
                .foregroundColor(.accentColor)
        }
    }
}

struct Widgets: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Events")
        .description("See how much time remaining for your events")
    }
}

struct Widgets_Previews: PreviewProvider {
    static let families: [WidgetFamily] = [
        .systemSmall,
        .systemMedium,
        .systemLarge,
        .systemExtraLarge,
        .accessoryRectangular,
        .accessoryCircular,
        .accessoryInline
    ]
    
    static var previews: some View {
        ForEach(families, id: \.self) { family in
            WidgetsEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: family))
                .previewDisplayName(family.description)
        }
    }
}
