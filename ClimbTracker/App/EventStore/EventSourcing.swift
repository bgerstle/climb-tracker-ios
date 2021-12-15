//
//  EventSourcing.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/14/21.
//

import Foundation
import Combine

protocol EventSourced {
    associatedtype Event: PersistableTopicEvent

    /*
     Going with this API since it allows types to enforce required attributes with `let`,
     as opposed to forcing structs to do things like `var requiredField: Type!` so they can be
     created "empty" and then have events applied.
    */
    static func apply(event: Event, to entity: Self?) -> Self
}

extension Publisher where Output: EventEnvelopeProtocol, Output.Event: PersistableTopicEvent {
    func materializedEntities<T: EventSourced>(_ entityType: T.Type) -> AnyPublisher<[T.ID: T], Failure>
    where T.Event == Output.Event,
          T: Identifiable,
          Output.Event: Identifiable,
          Output.Event.ID == T.ID
    {
        scan([T.ID: T]()) { (entities, eventEnvelope) in
            let currentEntityState = entities[eventEnvelope.event.id]
            let newEntityState = T.apply(event: eventEnvelope.event, to: currentEntityState)
            return entities.merging([newEntityState.id: newEntityState]) { _, new in new }
        }.eraseToAnyPublisher()
    }
}
