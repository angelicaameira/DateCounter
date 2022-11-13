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
            events = try PersistenceController.shared.container.viewContext.fetch(NSFetchRequest<Event>(entityName: "Event"))
        } catch {
            completion(nil, nil)
            return
        }
        
        if events.isEmpty {
            // Call the completion handler, passing the collection.
            completion(nil, nil)
            return
        }
        
        // Create a collection with the array of characters.
        var intentEvents = [EventType]()
        for event in events {
            if let idString = event.id?.uuidString,
               let title = event.title {
                intentEvents.append(EventType(identifier: idString, display: title))
            } else {
//                fatalError("failed to retrieve events")
                print("ERROR: Invalid event \(event)")
            }
        }
        let collection = INObjectCollection(items: intentEvents)
        completion(collection, nil)
        
    }
    
//    func provideEventOptionsCollection(for intent: EventSelectionIntent, with completion: @escaping (INObjectCollection<EventType>?, Error?) -> Void) {
//        // Iterate the available characters, creating a GameCharacter for each one.
//
////        let characters: [GameCharacter] = CharacterDetail.availableCharacters.map { character in
////            let gameCharacter = GameCharacter(
////                identifier: character.name,
////                display: character.name
////            )
////            gameCharacter.name = character.name
////            return gameCharacter
////        }
//
//
//    }
    
    func resolveEvent(for intent: EventSelectionIntent, with completion: @escaping (EventTypeResolutionResult) -> Void) {
        let collection = INObjectCollection(items: [
            EventType(identifier: "ID", display: "Meu evento 1"),
            EventType(identifier: "ID2", display: "Meu evento 2")
        ]) //(items: characters)
        
        completion(.success(with: EventType(identifier: "ID", display: "Meu evento 1")))

        // Call the completion handler, passing the collection.
//        completion(EventType(identifier: "ID", display: "Meu evento 1"))
    }
    
}
