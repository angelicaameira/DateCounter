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
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        ZStack {
            switch family {
            case .systemSmall: defaultView
            case .systemMedium: defaultView
            case .systemLarge: defaultView
            case .systemExtraLarge: defaultView
            case .accessoryCircular: accessoryCircular
            case .accessoryRectangular: accessoryRectangular
            case .accessoryInline: accessoryInline
            @unknown default: defaultView
            }
        }
    }
    
    var accessoryCircular: some View {
        ZStack {
//            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryWidgetBackground()
                ProgressView(timerInterval: dateRange, label: {
                    Text("Event title here")
                }, currentValueLabel: {
                    Text(dateForPeriod, style: .relative)
                        .font(.subheadline)
                })
                .progressViewStyle(.circular)
//            } else {
//                VStack(alignment: .center) {
//                    HStack(alignment: .center) {
//                        Text("Event title here")
//                          .textCase(.uppercase)
//                    }
//                    HStack(alignment: .center) {
//                        Spacer()
//                        Text(dateForPeriod, style: .relative)
//                    }
//                }
//                .font(.footnote)
//            }
        }
    }
    
    var dateRange: ClosedRange<Date> {
        return Date.now...dateForPeriod
    }
    
    var dateForPeriod: Date {
        let components = DateComponents(second: 100) //FIXME: biggest date bug? After 2150000000 it begins going down
        return Calendar.current.date(byAdding: components, to: Date.now)!
    }
    
    var defaultView: some View {
        return VStack(alignment: .leading) {
            Text("Event title that is large so that it can not possibly fit into the system small widget.")
                .truncationMode(.middle)
            Text(dateForPeriod, style: .relative)
                .font(.largeTitle)
                .foregroundColor(.orange)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
        }
        .padding()
    }
    
    var accessoryInline: some View {
        ViewThatFits {
            Text("Event title: \(dateForPeriod, style: .relative)")
            Text("Event title: \(dateForPeriod, style: .offset)")
            Text("(8h) Event title")
        }
    }
    
    var accessoryRectangular: some View {
        VStack(alignment: .leading) {
            Text("Event title")
                .font(.headline)
                .widgetAccentable()
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
#if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
#else
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
#endif
    }
}

struct Widgets_Previews: PreviewProvider {
#if !os(watchOS)
    static let families: [WidgetFamily] = [
        .systemSmall,
        .systemMedium,
        .systemLarge,
        .systemExtraLarge,
        .accessoryRectangular,
        .accessoryCircular,
        .accessoryInline
    ]
#else
    static let families: [WidgetFamily] = [
        .accessoryRectangular,
        .accessoryCircular,
        .accessoryInline
    ]
#endif
    
    static var previews: some View {
        ForEach(families, id: \.self) { family in
            WidgetsEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: family))
                .previewDisplayName(family.description)
        }
    }
}
