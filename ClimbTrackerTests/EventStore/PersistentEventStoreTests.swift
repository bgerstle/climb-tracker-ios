//
//  PersistentEventStoreTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/19/21.
//

import XCTest
import GRDB
import CombineExpectations
@testable import ClimbTracker

class PersistentEventStoreTests: XCTestCase {
    static var testDatabase: TestDatabase!

    var db: DatabaseWriter! { PersistentEventStoreTests.testDatabase.db }
    var eventStore: PersistentEventStore!

    override class func setUp() {
        testDatabase = TestDatabase.eventStore()
    }

    override func setUpWithError() throws {
        eventStore = try PersistentEventStore(db: db)
    }

    func testCreateTopic_GivenNoExistingTopic_ThenItSucceeds() async throws {
        let topic = try await eventStore.createTopic(id: "foo", eventType: TestEvent.self)

        XCTAssertEqual(topic.id, "foo")
    }

    func testNamespaceEvents_GivenTopic_WhenEventWritten_ThenItIsPublished() async throws {
        let event = TestEvent.test,
            envelope = EventEnvelope(event: event, timestamp: Date().truncatedToSeconds()),
            recorder: TestEventRecorder = eventStore.namespaceEvents().record()

        let topic = try await eventStore.createTopic(id: "foo", eventType: TestEvent.self)
        try await topic.write(envelope)

        let publishedEvents = try wait(for: recorder.availableElements, timeout: 1.0)
        XCTAssertEqual(publishedEvents, [envelope])
    }

    func testNamespaceEvents_GivenTwoTopics_WhenEventsWritten_ThenTheyArePublished() async throws {
        let event = TestEvent.test,
            topic1Events = [
                EventEnvelope(event: event, timestamp: Date().truncatedToSeconds()),
                EventEnvelope(event: event, timestamp: Date().addingTimeInterval(1).truncatedToSeconds())
            ],
            topic2Events = [
                EventEnvelope(event: event, timestamp: Date().addingTimeInterval(2).truncatedToSeconds()),
                EventEnvelope(event: event, timestamp: Date().addingTimeInterval(3).truncatedToSeconds())
            ],
            recorder: TestEventRecorder = eventStore.namespaceEvents().record()

        let topic1 = try await eventStore.createTopic(id: "foo", eventType: TestEvent.self)
        let topic2 = try await eventStore.createTopic(id: "bar", eventType: TestEvent.self)
        try await withThrowingTaskGroup(of: Void.self) { group in
            topic1Events.forEach { envelope in
                group.addTask {
                    try await topic1.write(envelope)
                }
            }
            topic2Events.forEach { envelope in
                group.addTask {
                    try await topic2.write(envelope)
                }
            }

            try await group.waitForAll()
        }


        let publishedEvents = try wait(for: recorder.availableElements, timeout: 1.0)
        XCTAssertEqual(publishedEvents, topic1Events + topic2Events)
    }
}
