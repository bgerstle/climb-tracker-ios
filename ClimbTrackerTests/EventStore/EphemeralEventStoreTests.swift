//
//  EphemeralEventStoreTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/12/21.
//

import XCTest
import Combine
import CombineExpectations
@testable import ClimbTracker

class EphemeralEventStoreTests: XCTestCase {
    var eventStore: EphemeralEventStore!

    override func setUp() {
        eventStore = EphemeralEventStore()
    }

    func testNamespaceEventsAsync_GivenTopicInNameSpace_WhenEventIsWritten_ThenNamespaceEventIsPublished() throws {
        let testEventEnvelope = EventEnvelope<TestEvent>(event: .test, timestamp: Date())

        let recorder: TestEventRecorder = try expectAsync {
            let events: AnyPublisher<EventEnvelope<TestEvent>, Never> = await self.eventStore.namespaceEventsAsync(),
                namespaceRecorder = events.record(),
                topic = try await self.eventStore.createTopic(id: "foo", eventType: TestEvent.self)

            try await topic.write(testEventEnvelope)

            return namespaceRecorder
        }

        let actualEvent = try self.wait(for: recorder.next(), timeout: 2.0)
        XCTAssertEqual(actualEvent, testEventEnvelope)
    }

    func testNamespaceEvents_GivenTopicInNameSpace_WhenEventIsWritten_ThenNamespaceEventIsPublished() throws {
        let events: AnyPublisher<EventEnvelope<TestEvent>, Never> = eventStore.namespaceEvents(),
            namespaceRecorder = events.record(),
            testEventEnvelope = EventEnvelope<TestEvent>(event: .test, timestamp: Date())

        try expectAsync {
            let topic = try await self.eventStore.createTopic(id: "foo", eventType: TestEvent.self)
            try await topic.write(testEventEnvelope)
        }

        let actualEvent = try self.wait(for: namespaceRecorder.next(), timeout: 2.0)
        XCTAssertEqual(actualEvent, testEventEnvelope)
    }
}
