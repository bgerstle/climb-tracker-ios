//
//  EphemeralEventStoreTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/11/21.
//

import XCTest
import Combine
import CombineExpectations
@testable import ClimbTracker

class EphemeralTopicTests: XCTestCase {
    var topic: EphemeralTopic<TestEvent>!

    override func setUp() {
        topic = EphemeralTopic<TestEvent>(id: "foo")
    }

    func testRead_GivenEmpty_WhenWritingElement_ThenOneEventPublished() throws {
        let testEventEnvelope = EventEnvelope<TestEvent>(event: .test, timestamp: Date()),
            recorder = topic.eventPublisher.record()

        try expectAsync {
            try await self.topic.write(testEventEnvelope)
        }

        let actualEvent = try self.wait(for: recorder.next(), timeout: 2.0)
        XCTAssertEqual(actualEvent, testEventEnvelope)
    }

    func testRead_GivenEmpty_WhenWritingTwoElements_ThenTwoEventsPublished() throws {
        let testEventEnvelope1 = EventEnvelope<TestEvent>(event: .test, timestamp: Date()),
            testEventEnvelope2 = EventEnvelope<TestEvent>(event: .test, timestamp: Date().addingTimeInterval(1)),
            recorder = topic.eventPublisher.record()

        try expectAsync {
            try await self.topic.write(testEventEnvelope1)
            try await self.topic.write(testEventEnvelope2)
        }

        let actualEvents = try self.wait(for: recorder.next(2), timeout: 2.0)
        XCTAssertEqual(actualEvents, [testEventEnvelope1, testEventEnvelope2])
    }

    func testReadAsync_GivenPriorElement_WhenWritingAnotherElement_ThenBothEventsPublished() throws {
        let testEventEnvelope1 = EventEnvelope<TestEvent>(event: .test, timestamp: Date()),
            testEventEnvelope2 = EventEnvelope<TestEvent>(event: .test, timestamp: Date().addingTimeInterval(1)),
            recorder = topic.eventPublisher.record()

        try expectAsync {
            try await self.topic.write(testEventEnvelope1)
            try await self.topic.write(testEventEnvelope2)
        }

        let actualEvents: [EventEnvelope<TestEvent>] =  try self.wait(for: recorder.next(2), timeout: 2.0)

        XCTAssertEqual(actualEvents, [testEventEnvelope1, testEventEnvelope2])
    }

    func testEvents_ReturnsSnapshotOfWrittenEvents() throws {
        let testEventEnvelope = EventEnvelope<TestEvent>(event: .test, timestamp: Date())

        let events: [EventEnvelope<TestEvent>] = try expectAsync {
            try await self.topic.write(testEventEnvelope)
            return try await self.topic.events()
        }


        XCTAssertEqual(events, [testEventEnvelope])
    }
}
