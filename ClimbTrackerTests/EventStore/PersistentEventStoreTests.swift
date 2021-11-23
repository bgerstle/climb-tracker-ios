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

    var db: DatabaseWriter! { TestDatabase.eventStore.db }
    
    var eventStore: PersistentEventStore!

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

    func testNamespaceEvents_GivenTopicWithWrittenEvent_WhenInvoked_ThenItIsPublishesPreexistingEvents() async throws {
        let event = TestEvent.test,
            envelope = EventEnvelope(event: event, timestamp: Date().truncatedToSeconds())

        let topic = try await eventStore.createTopic(id: "foo", eventType: TestEvent.self)
        try await topic.write(envelope)

        // get a fresh DB connection
        try TestDatabase.eventStore.close()
        try TestDatabase.eventStore.open()
        eventStore = try PersistentEventStore(db: db)

        let recorder: TestEventRecorder = eventStore.namespaceEvents().record()
        let publishedEvents = try wait(for: recorder.availableElements, timeout: 1.0)
        XCTAssertEqual(publishedEvents, [envelope])
    }

    func testNamespaceEvents_GivenTwoTopicsInNamespace_WhenEventsWritten_ThenTheyArePublished() async throws {
        let topic1Events = [
            EventEnvelope(event: TestEvent.associatedValue("1"), timestamp: Date().truncatedToSeconds()),
            EventEnvelope(event: TestEvent.associatedValue("2"), timestamp: Date().addingTimeInterval(1).truncatedToSeconds())
            ],
            topic2Events = [
                EventEnvelope(event: TestEvent.associatedValue("3"), timestamp: Date().addingTimeInterval(2).truncatedToSeconds()),
                EventEnvelope(event: TestEvent.associatedValue("4"), timestamp: Date().addingTimeInterval(3).truncatedToSeconds())
            ],
            recorder: TestEventRecorder = eventStore.namespaceEvents().record()

        let topic1 = try await eventStore.createTopic(id: "foo", eventType: TestEvent.self)
        let topic2 = try await eventStore.createTopic(id: "bar", eventType: TestEvent.self)
        try await withThrowingTaskGroup(of: Void.self) { group in
            topic1Events.forEach { envelope in
                group.addTask {
                    print("Starting task for \(envelope) from \(Thread.current) at \(Date().timeIntervalSince1970)")
                    try await topic1.write(envelope)
                    print("Finished task for \(envelope) at \(Date().timeIntervalSince1970)")
                }
            }
            topic2Events.forEach { envelope in
                group.addTask {
                    print("Starting task for \(envelope) from \(Thread.current) at \(Date().timeIntervalSince1970)")
                    try await topic2.write(envelope)
                    print("Finished task for \(envelope) at \(Date().timeIntervalSince1970)")
                }
            }

            try await group.waitForAll()
        }


        let publishedEvents = try wait(for: recorder.availableElements, timeout: 1.0)
        XCTAssertEqual(publishedEvents, topic1Events + topic2Events)
    }

    func testNamespaceEvents_GivenTwoTopicsInNamespace_WhenEventsWrittenSerially_ThenTheyArePublished() async throws {
        let topic1Events = [
            EventEnvelope(event: TestEvent.associatedValue("1"), timestamp: Date().truncatedToSeconds()),
            EventEnvelope(event: TestEvent.associatedValue("2"), timestamp: Date().addingTimeInterval(1).truncatedToSeconds())
            ],
            topic2Events = [
                EventEnvelope(event: TestEvent.associatedValue("3"), timestamp: Date().addingTimeInterval(2).truncatedToSeconds()),
                EventEnvelope(event: TestEvent.associatedValue("4"), timestamp: Date().addingTimeInterval(3).truncatedToSeconds())
            ],
            recorder: TestEventRecorder = eventStore.namespaceEvents().record()

        let topic1 = try await eventStore.createTopic(id: "foo", eventType: TestEvent.self)
        let topic2 = try await eventStore.createTopic(id: "bar", eventType: TestEvent.self)

        try topic1Events.forEach { envelope in
            try expectAsync {
                print("Starting task for \(envelope) from \(Thread.current) at \(Date().timeIntervalSince1970)")
                try await topic1.write(envelope)
                print("Finished task for \(envelope) at \(Date().timeIntervalSince1970)")
            }
        }

        try topic2Events.forEach { envelope in
            try expectAsync {
                print("Starting task for \(envelope) from \(Thread.current) at \(Date().timeIntervalSince1970)")
                try await topic2.write(envelope)
                print("Finished task for \(envelope) at \(Date().timeIntervalSince1970)")
            }
        }

        let publishedEvents = try wait(for: recorder.availableElements, timeout: 1.0)

        XCTAssertEqual(publishedEvents, topic1Events + topic2Events)
    }

    func testNamespaceEvents_GivenTwoTopicsInDiffNamespaces_WhenEventInOtherNSWritten_ThenOnlyPublishedInNS() async throws {
        let event = OtherTestEvent.test,
            otherNSEventEnvelope = EventEnvelope(event: event, timestamp: Date().truncatedToSeconds()),
            testRecorder: TestEventRecorder = eventStore.namespaceEvents().record(),
            otherTestRecorder: Recorder<EventEnvelope<OtherTestEvent>, Never> = eventStore.namespaceEvents().record()

        let otherNSTopic = try await eventStore.createTopic(id: "bar", eventType: OtherTestEvent.self)

        try await otherNSTopic.write(otherNSEventEnvelope)

        let publishedTestEvents = try wait(for: testRecorder.availableElements, timeout: 1.0)
        XCTAssertEqual(publishedTestEvents, [])

        let publishedOtherEvents = try wait(for: otherTestRecorder.availableElements, timeout: 1.0)
        XCTAssertEqual(publishedOtherEvents, [otherNSEventEnvelope])
    }
}
