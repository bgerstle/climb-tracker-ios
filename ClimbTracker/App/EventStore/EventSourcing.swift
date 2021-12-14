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
