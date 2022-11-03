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
                .frame(minWidth: 500, minHeight: 200)
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
    static let event: Event = {
        let event = Event(context: PersistenceController.preview.container.viewContext)
        event.title = "My awesome event"
        event.eventDescription = "Event description, which might be big so we have a somewhat lengthy description here, one that probably will break the window size for all platforms.\nMust be multiline as well!\nSuch description\nMany lines"
        event.date = Date(timeInterval: -82173681, since: Date())
        return event
    }()
    
    static var previews: some View {
        VStack {
            Text(event.title!)
            Text(event.eventDescription!)
        }
    }
}
