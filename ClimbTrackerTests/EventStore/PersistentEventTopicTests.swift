//
//  PersistentEventTopicTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/19/21.
//

import XCTest
import CombineExpectations
import GRDB
@testable import ClimbTracker

class PersistentEventTopicTests : XCTestCase {
    var topic: PersistentEventTopic<TestEvent>!

    static var testDatabase: TestDatabase!

    var db: DatabaseWriter! { PersistentEventTopicTests.testDatabase.db }

    override class func setUp() {
        testDatabase = TestDatabase.eventStore()
    }

    override func setUpWithError() throws {
        let dbTopic = DBTopic(id: "foo", namespace: TestEvent.namespace)
        try db.write { db in
            try dbTopic.save(db)
        }
        topic = PersistentEventTopic(dbTopic: dbTopic, db: db)
    }

    func testWrite_GivenEventWithoutPayload_WhenWritten_ThenPersistedInDatabase() async throws {
        let timestamp = Date(),
            event = TestEvent.test,
            envelope = EventEnvelope(event: event, timestamp: timestamp)

        try await topic.write(envelope)

        let dbEvents = try db.read { db in
            try DBEvent.fetchAll(db)
        }

        XCTAssertEqual(dbEvents.count, 1)
        guard let dbEvent = dbEvents.first else { XCTFail(); return }
        let timeDifference = timestamp.timeIntervalSince1970 - dbEvent.timestamp.timeIntervalSince1970
        XCTAssertTrue(abs(timeDifference) < 0.001)
        XCTAssertEqual(dbEvent.topicId, topic.id)
        XCTAssertEqual(dbEvent.event, TestEvent.PayloadType.test.rawValue)
        XCTAssertEqual(dbEvent.payload, Data())
    }

    func testEvents_GivenEventWritten_ThenResultIsThatEvent() async throws {
        let timestamp = Date().truncatedToSeconds(),
            event = TestEvent.test,
            envelope = EventEnvelope(event: event, timestamp: timestamp)

        try await topic.write(envelope)

        let events = try await topic.events()

        XCTAssertEqual(events, [envelope])
    }

    func testEventPublisher_GivenEventWritten_ThenEventIsPublished() async throws {
        let timestamp = Date().truncatedToSeconds(),
            event = TestEvent.test,
            envelope = EventEnvelope(event: event, timestamp: timestamp),
            recorder = topic.eventPublisher.record()

        try await topic.write(envelope)

        let publishedEnvelopes = try wait(for: recorder.availableElements, timeout: 2.0)

        XCTAssertEqual(publishedEnvelopes, [envelope])
    }


    func testWriteEvents_GivenEventWithPayload_WhenWritten_ThenPayloadIsPersisted() async throws {
        let timestamp = Date().truncatedToSeconds(),
            value = "foo",
            event = TestEvent.associatedValue(value),
            envelope = EventEnvelope(event: event, timestamp: timestamp)

        try await topic.write(envelope)

        let envelopes = try await topic.events()

        XCTAssertEqual(envelopes, [envelope])
    }

    func testEventPublisher_GivenTwoEventsWritten_ThenBothArePublished() async throws {
        let envelope1 = EventEnvelope(event: TestEvent.test,
                                      timestamp: Date().truncatedToSeconds()),
            envelope2 = EventEnvelope(event: TestEvent.associatedValue("bar"),
                                      timestamp: Date().addingTimeInterval(1).truncatedToSeconds()),
            recorder = topic.eventPublisher.record()

        try await topic.write(envelope1)
        try await topic.write(envelope2)

        let publishedEnvelopes = try wait(for: recorder.availableElements, timeout: 2.0)

        XCTAssertEqual(publishedEnvelopes, [envelope1, envelope2])
    }
}
