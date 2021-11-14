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

    func testNamespaceEvents_GivenTopicInNameSpace_WhenTwoEventsAreWritten_TheTwoNamespaceEventIsPublished() throws {
        let events: AnyPublisher<EventEnvelope<TestEvent>, Never> = eventStore.namespaceEvents(),
            namespaceRecorder = events.record(),
            testEventEnvelope1 = EventEnvelope<TestEvent>(event: .test, timestamp: Date()),
        testEventEnvelope2 = EventEnvelope<TestEvent>(event: .test, timestamp: Date().addingTimeInterval(1))


        try expectAsync {
            let topic = try await self.eventStore.createTopic(id: "foo", eventType: TestEvent.self)
            try await topic.write(testEventEnvelope1)
            try await topic.write(testEventEnvelope2)
        }

        let actualEvents = try self.wait(for: namespaceRecorder.availableElements, timeout: 1.0)
        XCTAssertEqual(actualEvents, [testEventEnvelope1, testEventEnvelope2])
    }

    func testNamespaceEvents_GivenTwoTopicsInNameSpace_WhenOneEventPerTopicIsWritten_TheTwoNamespaceEventIsPublished() throws {
        let events: AnyPublisher<EventEnvelope<TestEvent>, Never> = eventStore.namespaceEvents(),
            namespaceRecorder = events.record(),
            testEventEnvelope1 = EventEnvelope<TestEvent>(event: .test, timestamp: Date()),
        testEventEnvelope2 = EventEnvelope<TestEvent>(event: .test, timestamp: Date().addingTimeInterval(1))


        try expectAsync {
            let topic1 = try await self.eventStore.createTopic(id: "foo", eventType: TestEvent.self)
            let topic2 = try await self.eventStore.createTopic(id: "bar", eventType: TestEvent.self)
            try await topic1.write(testEventEnvelope1)
            try await topic2.write(testEventEnvelope2)
        }

        let actualEvents = try self.wait(for: namespaceRecorder.availableElements, timeout: 1.0)
        XCTAssertEqual(actualEvents, [testEventEnvelope1, testEventEnvelope2])
    }
}
