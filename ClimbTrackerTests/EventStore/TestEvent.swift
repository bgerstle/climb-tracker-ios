//
//  TestEvent.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/14/21.
//

import Foundation
@testable import ClimbTracker
import CombineExpectations

enum TestEvent : PersistableTopicEvent, Equatable {
    static var namespace: String { "test" }

    case test
    case associatedValue(String)

    enum PayloadType : String, CaseIterable, StringRawRepresentable {
        case test = "test"
        case associatedValue = "associatedValue"
    }

    var payloadType: PayloadType {
        switch self {
        case .test:
            return .test
        case .associatedValue(_):
            return .associatedValue
        }
    }

    var payload: Data {
        switch self {
        case .test:
            return Data()
        case .associatedValue(let value):
            return value.data(using: .utf8)!
        }
    }

    init?(payloadType: PayloadType, payload: Data) {
        switch payloadType {
        case .test:
            self = TestEvent.test
        case .associatedValue:
            guard let value = String(data: payload, encoding: .utf8) else {
                return nil
            }
            self = TestEvent.associatedValue(value)
        }
    }
}

typealias TestEventRecorder = Recorder<EventEnvelope<TestEvent>, Never>
