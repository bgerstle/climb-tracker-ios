//
//  Publisher+Log.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/17/21.
//

import Foundation
import Combine

// Utility to publish all current and future elements in an *append-only* collection
// TODO: use types to enforce append-only collection
extension Publisher where Output: Collection {
    var logPublisher: AnyPublisher<Output.Element, Failure> {
        // assumes elements are only appended so that new ones are always at the end,
        // which implies that the publisher only signals when new elements are added
        var offset = 0

        // use a queue to synchronize read/writes of offset
        let logPublisherQueue = DispatchQueue(label: "logPublisher")

        return receive(on: logPublisherQueue)
            .flatMap { updatedElements -> AnyPublisher<Output.Element, Never> in
            // every time the collection is updated, skip elements that have already been published
            let newElements = updatedElements.dropFirst(offset)

            // update last-seen offset
            offset += newElements.count

            // wrap new elements in a publisher which publishes one element at a time
            return Publishers.Sequence(sequence: newElements).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
