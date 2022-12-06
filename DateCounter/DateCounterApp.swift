//
//  DateCounterApp.swift
//  DateCounter
//
//  Created by Antonio Germano on 04/10/22.
//

import SwiftUI

@main
struct DateCounterApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
#if os(OSX)
                .frame(minWidth: 500, minHeight: 250)
#endif
        }
#if !os(watchOS)
        .commands {
            DateCounterCommands()
        }
#endif
        
#if os(macOS)
        Settings {
            Preferences()
        }
#endif
    }
}

struct TestData {
    static func event(period: Period?) -> Event {
        let event = Event(context: PersistenceController.preview.container.viewContext)
        let eventTitles = [
            "My awesome event",
            "Sister's birthday",
            "Doctor's appointment",
            "Buy groceries"
        ]
        event.title = eventTitles.randomElement()
        event.eventDescription = "Event description, which might be big so we have a somewhat lengthy description here, one that probably will break the window size for all platforms.\nMust be multiline as well!\nSuch description\nMany lines\nSo much space"
        let timeInterval: TimeInterval
        let actualPeriod: Period
        if let period = period {
            actualPeriod = period
        } else {
            actualPeriod = Period.allCases.randomElement()!
        }
        switch actualPeriod {
        case .past:
            timeInterval = -82173681
        case .month:
            timeInterval = 150000
        case .semester:
            timeInterval = 5173681
        case .year:
            timeInterval = 22173681
        case .decade:
            timeInterval = 82173681
        }
        
        event.date = Date(timeInterval: timeInterval, since: Date.now)
        return event
    }
}

#if !TEST
struct DateCounterApp_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            Text(TestData.event(period: .month).title!)
            Text(TestData.event(period: .month).eventDescription!)
            Text(TestData.event(period: .month).date!.formatted())
        }
    }
}
#endif
