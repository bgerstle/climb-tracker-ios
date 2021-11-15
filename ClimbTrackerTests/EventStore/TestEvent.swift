//
//  TestEvent.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/14/21.
//

import Foundation
@testable import ClimbTracker
import CombineExpectations

enum TestEvent : TopicEvent {
    static var namespace: String { "test" }

    case test
}

typealias TestEventRecorder = Recorder<EventEnvelope<TestEvent>, Error>
