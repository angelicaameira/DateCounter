//
//  Persistence.swift
//  DateCounter
//
//  Created by Antonio Germano on 04/10/22.
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()
  static let readOnly = PersistenceController(readOnly: true)
  
  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    
    for index in 1..<10 {
      let event = Event(context: viewContext)
      event.title = "Preview event \(index)"
      event.eventDescription = "Event \(index) description, which might be big so we have a somewhat lengthy description here"
      event.date = Date(timeInterval: TimeInterval(1000000 * index * index), since: Date())
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
  
  init(inMemory: Bool = false, readOnly: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "DateCounter")
    
    let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.br.com.angelicameira.DateCounter")!
    let storeURL = containerURL.appendingPathComponent("DateCounter.sqlite")
    let shared = NSPersistentStoreDescription(url: storeURL)
    
    shared.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    shared.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
    shared.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.br.com.angelicameira.DateCounter")
    shared.isReadOnly = readOnly
    
    container.persistentStoreDescriptions = [ shared ]
// #if DEBUG
//    do {
//        try container.initializeCloudKitSchema()
//    } catch {
//        print("Failed to initialize CloudKit: \(error)")
//    }
// #endif
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores { storeDescription, error in
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
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
}
