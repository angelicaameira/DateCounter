//
//  IntentHandler.swift
//  EventIntents
//
//  Created by Antonio Germano on 11/11/22.
//

import Intents
import CoreData

class IntentHandler: INExtension, EventSelectionIntentHandling {
#if APPSTORE_SCREENSHOTS
  let persistenceController = PersistenceController.preview
#else
  let persistenceController = PersistenceController.readOnly
#endif
  
  func provideEventOptionsCollection(for intent: EventSelectionIntent, with completion: @escaping (INObjectCollection<EventType>?, Error?) -> Void) {
    let events: [Event]
    do {
      let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
      fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
      events = try persistenceController.container.viewContext.fetch(fetchRequest)
    } catch {
      completion(nil, NSError(domain: "Failed to retrieve Event list from CoreData", code: -1))
      return
    }
    
    if events.isEmpty {
      completion(nil, nil)
      return
    }
    
    // Create a collection with the array of characters.
    var intentEvents: [EventType] = []
    for event in events {
      guard
        let idString = event.id?.uuidString,
        let title = event.title
      else {
        continue
      }
      intentEvents.append(EventType(identifier: idString, display: title))
    }
    let collection = INObjectCollection(items: intentEvents)
    completion(collection, nil)
  }
}
