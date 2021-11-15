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

                try self.expectAsync {
                    try await self.service.create(grade: expectedGrade)
                }

                let publishedEventEnvelope: EventEnvelope<BoulderProject.Event> =
                    try self.wait(for: recorder.next(), timeout: 2.0)

                if case .created(let event) = publishedEventEnvelope.event {
                    XCTAssertEqual(event.grade, expectedGrade.any)
                    // FIXME: inject current time for testing
                    // XCTAssertEqual(actualClimb.createdAt, climbedAt)
                } else {
                    XCTFail("Unexpected case: \(publishedEventEnvelope)")
                }
            }

            it("It emits a boulder project created event with a font grade") {
                let recorder: BoulderEventRecorder = self.eventStore.namespaceEvents().record(),
                    expectedGrade = FontGrade.sixAPlus

                try self.expectAsync {
                    try await self.service.create(grade: expectedGrade)
                }

                let publishedEventEnvelope: EventEnvelope<BoulderProject.Event> =
                    try self.wait(for: recorder.next(), timeout: 2.0)

                if case .created(let event) = publishedEventEnvelope.event {
                    XCTAssertEqual(event.grade, expectedGrade.any)
                } else {
                    XCTFail("Unexpected case: \(publishedEventEnvelope)")
                }
            }
        }
    }
}
