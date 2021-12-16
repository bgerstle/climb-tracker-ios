//
//  EventSourcing.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/14/21.
//

import Foundation
import Combine

protocol EventSourced {
    associatedtype Event: PersistableTopicEvent, Identifiable

    /*
     Going with this API since it allows types to enforce required attributes with `let`,
     as opposed to forcing structs to do things like `var requiredField: Type!` so they can be
     created "empty" and then have events applied.
    */
    static func apply(event: Event, to entity: Self?) -> Self
}

actor Materializer<Entity: EventSourced> {
    var entities = [Entity.Event.ID: Entity]()
}

extension Materializer where Entity.Event: PersistableTopicEvent, Entity.Event: Identifiable {
    func apply(_ event: Entity.Event) -> Entity {
        let currentEntityState = entities[event.id]
        let newEntityState = Entity.apply(event: event, to: currentEntityState)
        entities[event.id] = newEntityState
        return newEntityState
    }
}

extension Publisher where Output: EventEnvelopeProtocol, Output.Event: PersistableTopicEvent {
    func materializedEntities<Entity: EventSourced>(_ entityType: Entity.Type) -> AnyPublisher<Entity, Failure> where Entity.Event == Output.Event {
        let materializer = Materializer<Entity>()
        return map { eventEnvelope in
                Future { promise in
                    Task {
                        promise(.success(await materializer.apply(eventEnvelope.event)))
                    }
                }
            }
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }
}
