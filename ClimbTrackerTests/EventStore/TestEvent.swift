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

    func payload() throws -> Data {
        switch self {
        case .test:
            return Data()
        case .associatedValue(let value):
            guard let data = value.data(using: .utf8) else {
                throw TestEventPayloadEncodingError(payload: value)
            }
            return data
        }
    }

    init(payloadType: PayloadType, payload: Data) throws {
        switch payloadType {
        case .test:
            self = TestEvent.test
        case .associatedValue:
            guard let value = String(data: payload, encoding: .utf8) else {
                throw TestEventPayloadDecodingError(payload: payload)
            }
            self = TestEvent.associatedValue(value)
        }
    }
}

struct TestEventPayloadEncodingError : Error {
    let payload: String
}

struct TestEventPayloadDecodingError : Error {
    let payload: Data
}

typealias TestEventRecorder = Recorder<EventEnvelope<TestEvent>, Never>
