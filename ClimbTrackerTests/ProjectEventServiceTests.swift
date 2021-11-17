//
//  ClimbServiceTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import XCTest
import Quick
import Combine
import CombineExpectations
@testable import ClimbTracker

class ProjectEventServiceTests: QuickSpec {
    typealias BoulderEventRecorder = Recorder<EventEnvelope<BoulderProject.Event>, Never>
    typealias RopeEventRecorder = Recorder<EventEnvelope<RopeProject.Event>, Never>

    var service: ProjectEventService! = nil
    var eventStore: EphemeralEventStore! = nil

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.eventStore = EphemeralEventStore()
            self.service = ProjectEventService(eventStore: self.eventStore)
        }

        describe("Creating boulder projects") {
            it("It emits a boulder project created event with a hueco grade") {
                let recorder: BoulderEventRecorder = self.eventStore.namespaceEvents().record(),
                    expectedGrade = HuecoGrade.easy

                let createdProjectId = try self.expectAsync {
                    try await self.service.create(grade: expectedGrade)
                }

                let publishedEventEnvelope: EventEnvelope<BoulderProject.Event> =
                    try self.wait(for: recorder.next(), timeout: 2.0)

                if case .created(let event) = publishedEventEnvelope.event {
                    XCTAssertEqual(event.grade, expectedGrade.any)
                    // FIXME: inject current time for testing
                    // XCTAssertEqual(actualClimb.createdAt, climbedAt)
                    XCTAssertEqual(event.projectId, createdProjectId)
                } else {
                    XCTFail("Unexpected case: \(publishedEventEnvelope)")
                }
            }

            it("It emits a boulder project created event with a font grade") {
                let recorder: BoulderEventRecorder = self.eventStore.namespaceEvents().record(),
                    expectedGrade = FontGrade.sixAPlus

                let createdProjectId = try self.expectAsync {
                    try await self.service.create(grade: expectedGrade)
                }

                let publishedEventEnvelope: EventEnvelope<BoulderProject.Event> =
                    try self.wait(for: recorder.next(), timeout: 2.0)

                if case .created(let event) = publishedEventEnvelope.event {
                    XCTAssertEqual(event.grade, expectedGrade.any)
                    XCTAssertEqual(event.projectId, createdProjectId)
                } else {
                    XCTFail("Unexpected case: \(publishedEventEnvelope)")
                }
            }
        }

        describe("Creating rope projects") {
            it("It emits a rope project created event with a yosemite grade") {
                let recorder: RopeEventRecorder = self.eventStore.namespaceEvents().record(),
                    expectedGrade = YosemiteDecimalGrade.tenA

                let createdProjectId = try self.expectAsync {
                    try await self.service.create(grade: expectedGrade)
                }

                let publishedEventEnvelope: EventEnvelope<RopeProject.Event> =
                    try self.wait(for: recorder.next(), timeout: 2.0)

                if case .created(let event) = publishedEventEnvelope.event {
                    XCTAssertEqual(event.grade, expectedGrade.any)
                    // FIXME: inject current time for testing
                    // XCTAssertEqual(actualClimb.createdAt, climbedAt)
                    XCTAssertEqual(event.projectId, createdProjectId)
                } else {
                    XCTFail("Unexpected case: \(publishedEventEnvelope)")
                }
            }

            it("It emits a rope project created event with a french grade") {
                let recorder: RopeEventRecorder = self.eventStore.namespaceEvents().record(),
                    expectedGrade = FrenchGrade.sixA

                let createdProjectId = try self.expectAsync {
                    try await self.service.create(grade: expectedGrade)
                }

                let publishedEventEnvelope: EventEnvelope<RopeProject.Event> =
                    try self.wait(for: recorder.next(), timeout: 2.0)

                if case .created(let event) = publishedEventEnvelope.event {
                    XCTAssertEqual(event.grade, expectedGrade.any)
                    // FIXME: inject current time for testing
                    // XCTAssertEqual(actualClimb.createdAt, climbedAt)
                    XCTAssertEqual(event.projectId, createdProjectId)
                } else {
                    XCTFail("Unexpected case: \(publishedEventEnvelope)")
                }
            }
        }

        describe("Logging rope attempts") {
            it("Logs an attempted event on the specified rope project") {
                let recorder: RopeEventRecorder = self.eventStore.namespaceEvents().record(),
                    expectedGrade = YosemiteDecimalGrade.tenA

                let createdProjectId = try self.expectAsync {
                    try await self.service.create(grade: expectedGrade)
                }

                let attemptedAt = Date(),
                    didSend = true,
                    subcategory = RopeProject.Subcategory.sport

                let createdAttemptId = try self.expectAsync {
                    try await self.service.attempt(projectId: createdProjectId, at: attemptedAt, didSend: didSend, subcategory: subcategory)
                }

                let publishedAttemptEventEnvelope: EventEnvelope<RopeProject.Event> =
                try self.wait(for: recorder.next(), timeout: 2.0)

                if case .attempted(let event) = publishedAttemptEventEnvelope.event {
                    XCTAssertEqual(createdProjectId, event.projectId)
                    XCTAssertEqual(didSend, event.didSend)
                    XCTAssertEqual(attemptedAt, event.attemptedAt)
                    XCTAssertEqual(subcategory, event.subcategory)
                    XCTAssertEqual(createdAttemptId, event.attemptId)
                }
            }
        }

        describe("Logging boulder attempts") {
            it("Logs an attempted event on the specified boulder project") {
                let recorder: BoulderEventRecorder = self.eventStore.namespaceEvents().record(),
                    expectedGrade = HuecoGrade.four

                let createdProjectId = try self.expectAsync {
                    try await self.service.create(grade: expectedGrade)
                }

                let attemptedAt = Date(),
                    didSend = true

                let createdAttemptId = try self.expectAsync {
                    try await self.service.attempt(projectId: createdProjectId, at: attemptedAt, didSend: didSend)
                }

                let publishedAttemptEventEnvelope: EventEnvelope<BoulderProject.Event> =
                try self.wait(for: recorder.next(), timeout: 2.0)

                if case .attempted(let event) = publishedAttemptEventEnvelope.event {
                    XCTAssertEqual(createdProjectId, event.projectId)
                    XCTAssertEqual(didSend, event.didSend)
                    XCTAssertEqual(attemptedAt, event.attemptedAt)
                    XCTAssertEqual(createdAttemptId, event.attemptId)
                }
            }
        }
    }
}
