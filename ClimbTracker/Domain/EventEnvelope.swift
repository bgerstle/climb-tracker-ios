//
//  EventEnvelope.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

struct EventEnvelope<T> {
    let event: T
    let timestamp: Date
}

protocol Topic {
    associatedtype EventType
}
