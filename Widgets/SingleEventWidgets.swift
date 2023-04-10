//
//  SingleEventWidgets.swift
//  Widgets
//
//  Created by Antonio Germano on 08/11/22.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: IntentTimelineProvider {
  static let placeholderIdentifier = "placeholder identifier"
  static let placeholderEventType: EventType = {
    EventType(identifier: placeholderIdentifier, display: "Awesome display")
  }()
  
  @available(macOSApplicationExtension 13.0, *)
  func recommendations() -> [IntentRecommendation<EventSelectionIntent>] {
    return []
  }
  
  static func event(for selectedEvent: EventType?) -> Event? {
#if APPSTORE_SCREENSHOTS
    let viewContext = PersistenceController.preview.container.viewContext
#else
    let viewContext = PersistenceController.readOnly.container.viewContext
#endif
    
    guard
      let selectedEvent = selectedEvent,
      let identifier = selectedEvent.identifier
    else {
      let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
      fetchRequest.fetchLimit = 1
      do {
        let events = try viewContext.fetch(fetchRequest)
        if let event = events.first {
          return event
        }
      } catch {
        print("Error \(error)")
      }
      return nil
    }
    
    if identifier == placeholderIdentifier {
      let title: LocalizedStringKey = "My awesome event"
      let description: LocalizedStringKey = "Event description"
      
      let event: Event
      event = Event(context: viewContext)
      event.title = "\(title)"
      event.eventDescription = "\(description)"
      event.date = Date(timeInterval: 150000, since: Date.now)
      return event
    }
    
    let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
    fetchRequest.predicate = NSPredicate(format: "id = %@", identifier)
    fetchRequest.fetchLimit = 1
    do {
      let events = try viewContext.fetch(fetchRequest)
      if let event = events.first {
        return event
      }
    } catch {
      print("Error \(error)")
    }
    return nil
  }
  
  var placeholderDate: Date {
    let components = DateComponents(second: 150000) // FIXME: biggest date bug? After 2150000000 it begins going down
    return Calendar.current.date(byAdding: components, to: Date.now)!
  }
  
  func placeholder(in context: Context) -> EventEntry {
    EventEntry(event: Provider.event(for: Provider.placeholderEventType), date: placeholderDate, configuration: EventSelectionIntent())
  }
  
  func getSnapshot(for configuration: EventSelectionIntent, in context: Context, completion: @escaping (EventEntry) -> Void) {
    let entry = EventEntry(event: Provider.event(for: configuration.event), date: Date.now, configuration: configuration)
    
    completion(entry)
  }
  
  func getTimeline(for configuration: EventSelectionIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let entries: [EventEntry] = [EventEntry(event: Provider.event(for: configuration.event), date: Date.now, configuration: configuration)]
    
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

struct EventEntry: TimelineEntry {
  let event: Event?
  var title: String { event?.title ?? "Unnamed event" }
  var description: String { event?.eventDescription ?? "" }
  var eventDate: Date { event?.date ?? Date.now }
  
  let date: Date
  let configuration: EventSelectionIntent
}

struct EventWidgetView: View {
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
    case .accessoryCorner: defaultView
    @unknown default: defaultView
    }
  }
  
  var resizableIcon: some View {
    Image(systemName: "calendar.badge.exclamationmark")
      .resizable()
      .aspectRatio(contentMode: .fit)
  }
  
  var noEventSelected: some View {
    ZStack(alignment: .center) {
      resizableIcon
        .foregroundColor(.orange)
        .opacity(0.2)
      if #available(macOSApplicationExtension 13.0, *) {
        ViewThatFits(in: .vertical) {
          Group {
            Text("Please edit this widget and choose an event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 10")
            Text("Please edit this widget to pick an event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 9")
            Text("Edit this widget and choose an event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 8")
            Text("Edit this widget to pick an event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 7")
            Text("Edit to choose an event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 6")
            Text("Edit to pick an event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 5")
            Text("Choose an event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 4")
            Text("Pick an event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 3")
            Text("Choose event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 2")
            Text("No event", comment: "Explains user action needed to show an event on this widget. There are 10 possible text lengths (so it adapts to screen available space), from biggest (10) to smallest (1). This is size 1")
          }
          .multilineTextAlignment(.center)
          Image(systemName: "calendar.badge.exclamationmark")
            .font(.largeTitle)
        }
      } else {
        // Fallback on earlier versions
        Text("Choose an event", comment: "Choose a event from event list"
        )
        .multilineTextAlignment(.center)
        Image(systemName: "calendar.badge.exclamationmark")
          .font(.largeTitle)
      }
    }
    .padding()
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
  
  @ViewBuilder
  var accessoryCircular: some View {
    if entry.event == nil {
      noEventSelected
    } else {
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
              Text(entry.title)
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
  }
  
  @ViewBuilder
  var defaultView: some View {
    if entry.event == nil {
      noEventSelected
    } else {
      VStack(alignment: .leading) {
        Text(entry.title)
          .font(.title)
          .truncationMode(.middle)
          .minimumScaleFactor(0.5)
          .padding(.bottom, 0.1)
          .foregroundColor(.orange)
        
        if !entry.description.isEmpty {
          Text(entry.description)
            .truncationMode(.middle)
            .foregroundColor(.secondary)
            .font(.subheadline)
            .minimumScaleFactor(0.65)
            .padding(.bottom, 0.1)
        }
        VStack(alignment: .trailing) {
          Text(entry.eventDate, style: .relative)
            .font(.title)
            .minimumScaleFactor(0.5)
            .opacity(0.65)
        }
      }
      .padding()
    }
  }
  
  @ViewBuilder
  var accessoryInline: some View {
    if entry.event == nil {
      noEventSelected
    } else {
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
  }
  
  @ViewBuilder
  var accessoryRectangular: some View {
    if entry.event == nil {
      noEventSelected
    } else {
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
}

struct SingleEventWidgets: Widget {
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

#if !TEST
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
  
#if !TEST
  static var previews: some View {
    ForEach(families, id: \.self) { family in
      Group {
        EventWidgetView(entry: EventEntry(event: nil, date: Date.now, configuration: EventSelectionIntent()))
          .previewContext(WidgetPreviewContext(family: family))
          .previewDisplayName("No event \(family.description)")
        EventWidgetView(entry: EventEntry(event: Provider.event(for: Provider.placeholderEventType), date: Date.now, configuration: EventSelectionIntent()))
          .previewContext(WidgetPreviewContext(family: family))
          .previewDisplayName(family.description)
      }
    }
  }
#endif
}
#endif
