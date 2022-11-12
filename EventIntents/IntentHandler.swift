//
//  IntentHandler.swift
//  EventIntents
//
//  Created by Antonio Germano on 11/11/22.
//

import Intents

class IntentHandler: INExtension, EventSelectionIntentHandling {
    
    func provideEventOptionsCollection(for intent: EventSelectionIntent, with completion: @escaping (INObjectCollection<EventType>?, Error?) -> Void) {
        // Create a collection with the array of characters.
        let collection = INObjectCollection(items: [
            EventType(identifier: "ID", display: "Meu evento 1"),
            EventType(identifier: "ID2", display: "Meu evento 2")
        ]) //(items: characters)

        // Call the completion handler, passing the collection.
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
