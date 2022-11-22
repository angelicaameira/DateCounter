//
//  Persistence.swift
//  DateCounter
//
//  Created by Antonio Germano on 04/10/22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let eventsDictionary: [(title: String, description: String)] = [
            (title: "Visit mom", description: "We'll stay at her house for the weekend"),
            (title: "Sara's Birthday", description: "Surprise party"),
            (title: "New year's eve", description: ""),
            (title: "Vacation", description: "We're going to the beach!"),
            (title: "Routine annual doctor's appointment", description: ""),
            (title: "Travel to Las Vegas", description: "A weekend we'll never forget"),
            (title: "Bring pet to the vet", description: "She needs to take her vaccines"),
            (title: "Disney trip", description: ""),
            (title: "Reunion with long-distance friends", description: "I'm so excited to see everyone again"),
            (title: "Graduation", description: "")
        ]
        
        var index = 1
        for previewEvent in eventsDictionary {
            let event = Event(context: viewContext)
            event.title = previewEvent.title
            event.eventDescription = previewEvent.description
            event.date = Date(timeInterval: TimeInterval(1000000*index*index), since: Date.now)
            index += 1
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.br.com.angelicameira.DateCounter")!
        let storeURL = containerURL.appendingPathComponent("DateCounter.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        
        container = NSPersistentCloudKitContainer(name: "DateCounter")
        container.persistentStoreDescriptions = [description]
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
