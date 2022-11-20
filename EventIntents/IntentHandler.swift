//
//  IntentHandler.swift
//  EventIntents
//
//  Created by Antonio Germano on 11/11/22.
//

import Intents
import CoreData

class IntentHandler: INExtension, EventSelectionIntentHandling {
    
    func provideEventOptionsCollection(for intent: EventSelectionIntent, with completion: @escaping (INObjectCollection<EventType>?, Error?) -> Void) {
        let events: [Event]
        do {
            let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            events = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        } catch {
            completion(nil, nil)//NSError(domain: "Failed to retrieve Event list from CoreData", code: -1))
            return
        }
        
        if events.isEmpty {
            completion(nil, nil) // TODO: maybe add error here too?
            return
        }
        
        // Create a collection with the array of characters.
        var intentEvents = [EventType]()
        for event in events {
            guard
                let idString = event.id?.uuidString,
                let title = event.title
            else {
//#if DEBUG
//                fatalError("failed to retrieve event \(event)")
//#else
                continue
//#endif
            }
            intentEvents.append(EventType(identifier: idString, display: title))
        }
        let collection = INObjectCollection(items: intentEvents)
        completion(collection, nil)
    }
    
//    static var PLACEHOLDER_IDENTIFIER = "placeholder identifier"
//
//    func defaultEvent(for intent: EventSelectionIntent) -> EventType? {
//        var events: [Event] = []
//        do {
//            let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
//            fetchRequest.fetchLimit = 1
//            events = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
//        } catch {
////#if DEBUG
////            fatalError("Failed to retrieve event")
////#endif
//        }
//
//        if !events.isEmpty,
//           let event = events.first,
//           let id = event.id {
//            return EventType(identifier: id.uuidString, display: "")
//        }
//        return EventType(identifier: IntentHandler.PLACEHOLDER_IDENTIFIER, display: "")
//    }
    
}
