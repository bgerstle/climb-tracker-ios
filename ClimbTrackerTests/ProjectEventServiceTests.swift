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
    typealias TestClimbEventSubject = PassthroughSubject<EventEnvelope<BoulderProject.Event>, Never>
    var eventSubject: TestClimbEventSubject! = nil
    var service: BoulderProjectEventService<TestClimbEventSubject>! = nil

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.eventSubject = TestClimbEventSubject()
            self.service = BoulderProjectEventService(subject: self.eventSubject)
        }

        describe("Creating climbs") {
            it("It emits a boulder project created event with a hueco grade") {
                let recorder = self.eventSubject.record(),
                    expectedGrade = HuecoGrade.easy

                self.service.create(grade: expectedGrade)

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
                let recorder = self.eventSubject.record(),
                    expectedGrade = FontGrade.sixAPlus

                self.service.create(grade: expectedGrade)

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
