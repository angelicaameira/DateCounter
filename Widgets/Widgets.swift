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
    
    static let placeholderEventType: EventType = {
        EventType(identifier: "Awesome identifier", display: "Awesome display")
    }()
    
    static func event(for selectedEvent: EventType?) -> Event {
        let event = Event(context: PersistenceController.preview.container.viewContext)
        
        if let selectedEvent = selectedEvent {
            event.title = selectedEvent.displayString
            event.eventDescription = selectedEvent.eventDescription
            //"Event description, which might be big so we have a somewhat lengthy description here, one that probably will break the window size for all platforms.\nMust be multiline as well!\nSuch description\nMany lines"
        } else {
            event.title = "My awesome event"
            event.eventDescription = "Event description, which might be big so we have a somewhat lengthy description here, one that probably will break the window size for all platforms.\nMust be multiline as well!\nSuch description\nMany lines"
        }
        event.date = Date(timeInterval: 150000, since: Date.now)
        // max TimeInterval: 15926483100000
        return event
    }
    
    var dateForPeriod: Date {
        let components = DateComponents(second: 150000) //FIXME: biggest date bug? After 2150000000 it begins going down
        return Calendar.current.date(byAdding: components, to: Date.now)!
    }
    
    func placeholder(in context: Context) -> EventEntry {
        EventEntry(event: Provider.event(for: Provider.placeholderEventType), date: dateForPeriod, configuration: EventSelectionIntent())
    }
    
    func getSnapshot(for configuration: EventSelectionIntent, in context: Context, completion: @escaping (EventEntry) -> ()) {
        let entry = EventEntry(event: Provider.event(for: configuration.event), date: Date.now, configuration: configuration)
        
        completion(entry)
    }
    
    func getTimeline(for configuration: EventSelectionIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [EventEntry] = [EventEntry(event: Provider.event(for: configuration.event), date: Date.now, configuration: configuration)]
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct EventEntry: TimelineEntry {
    let event: Event
    var title: String { event.title ?? "Unnamed event" }
    var description: String { event.eventDescription ?? "" }
    var eventDate: Date { event.date ?? Date.now }
    
    let date: Date
    let configuration: EventSelectionIntent
}

struct EventWidgetView : View {
    @Environment(\.widgetFamily) var family
#if !os(OSX)
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
#endif
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
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
    
    var dateRange: ClosedRange<Date> {
        if Date.now.compare(entry.eventDate).rawValue < 0 {
            return Date.now...entry.eventDate
        }
        return entry.eventDate...Date.now
    }
    
    var eventHourComponent: String {
        let dateComponents = Calendar.current.dateComponents([.hour], from: Date.now, to: entry.eventDate)
        let hourString = dateComponents.value(for: .hour)?.description
        return hourString ?? ""
    }
    
    var accessoryCircular: some View {
        ZStack {
            if #available(iOSApplicationExtension 16.0, *),
               #available(macOSApplicationExtension 13.0, *) {
                AccessoryWidgetBackground()
                ProgressView(timerInterval: dateRange, label: {
                    Text(entry.title)
                }, currentValueLabel: {
                    Text(entry.eventDate, style: .relative)
                        .font(.subheadline)
                })
                .progressViewStyle(.circular)
            } else {
                VStack(alignment: .center) {
                    HStack(alignment: .center) {
                        Text("Event title here")
                            .textCase(.uppercase)
                    }
                    HStack(alignment: .center) {
                        Spacer()
                        Text(entry.eventDate, style: .relative)
                    }
                }
                .font(.footnote)
            }
        }
    }
    
    var defaultView: some View {
        //        ZStack {
        //            AccessoryWidgetBackground()
        VStack(alignment: .leading) {
            Spacer()
            Text(entry.title)
                .truncationMode(.middle)
            Text(entry.eventDate, style: .relative)
                .font(.largeTitle)
                .foregroundColor(.orange)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            Spacer()
        }
        //        }
        .padding()
        //        .background(ContainerRelativeShape().fill(Color.init(.sRGB, red: 0.89, green: 0.89, blue: 0.89, opacity: 0.9)))
    }
    
    @ViewBuilder
    var accessoryInline: some View {
        if #available(macOSApplicationExtension 13.0, *) {
            ViewThatFits {
                Text("\(entry.title): \(entry.eventDate, style: .relative)")
                Text("\(entry.title): \(entry.eventDate, style: .offset)")
                if eventHourComponent.isEmpty {
                    Text(entry.title)
                } else {
                    Text("(\(eventHourComponent)h) \(entry.title)")
                }
            }
        } else {
            Text("\(entry.title): \(entry.eventDate, style: .relative)")
        }
    }
    
    var accessoryRectangular: some View {
        VStack(alignment: .leading) {
            Text(entry.title)
                .font(.headline)
#if !os(OSX)
                .widgetAccentable()
#endif
            Text(entry.description)
                .foregroundColor(.secondary)
                .font(.footnote)
            Text(entry.eventDate, style: .relative)
                .foregroundColor(.accentColor)
        }
    }
}

struct Widgets: Widget {
    let kind: String = "com.angelicameira.DateCounter.Event"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: EventSelectionIntent.self, provider: Provider()) { entry in
            EventWidgetView(entry: entry)
        }
        .configurationDisplayName("Events")
        .description("See the remaining time for your events")
#if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
#endif
#if os(iOS)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
#endif
#if os(OSX)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
#endif
    }
}

struct Widgets_Previews: PreviewProvider {
#if os(OSX)
    static let families: [WidgetFamily] = [
        .systemSmall,
        .systemMedium,
        .systemLarge
    ]
#endif
#if os(iOS)
    static let families: [WidgetFamily] = [
        .systemSmall,
        .systemMedium,
        .systemLarge,
        .systemExtraLarge,
        .accessoryRectangular,
        .accessoryCircular,
        .accessoryInline
    ]
#endif
#if os(watchOS)
    static let families: [WidgetFamily] = [
        .accessoryRectangular,
        .accessoryCircular,
        .accessoryInline
    ]
#endif
    
    static var previews: some View {
        ForEach(families, id: \.self) { family in
            Group {
                EventWidgetView(entry: EventEntry(event: Provider.event(for: Provider.placeholderEventType), date: Date.now, configuration: EventSelectionIntent()))
                    .previewContext(WidgetPreviewContext(family: family))
                    .previewDisplayName(family.description)
            }
        }
    }
}
