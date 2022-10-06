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
        }
    }
}
