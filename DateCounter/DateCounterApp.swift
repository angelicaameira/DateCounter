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
        .commands {
            DateCounterCommands()
        }
        
#if os(macOS)
        Settings {
            Preferences()
        }
#endif
    }
}

struct DateCounterApp_Previews: PreviewProvider {
    
    static func event(period: Period?) -> Event {
        let event = Event(context: PersistenceController.preview.container.viewContext)
        let eventTitles = [
            "My awesome event",
            "Sister's birthday",
            "Doctor's appointment",
            "Buy groceries"
        ]
        event.title = eventTitles.randomElement()
        event.eventDescription = "Event description, which might be big so we have a somewhat lengthy description here, one that probably will break the window size for all platforms.\nMust be multiline as well!\nSuch description\nMany lines"
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
    
    static var previews: some View {
        VStack {
            Text(event(period: .month).title!)
            Text(event(period: .month).eventDescription!)
            Text(event(period: .month).date!.formatted())
        }
    }
}
