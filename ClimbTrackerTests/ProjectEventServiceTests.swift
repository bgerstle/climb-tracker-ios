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
    typealias TestClimbEventSubject = PassthroughSubject<EventEnvelope<ProjectEvent>, Never>
    var eventSubject: TestClimbEventSubject! = nil
    var service: ProjectEventService<TestClimbEventSubject>! = nil

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.eventSubject = TestClimbEventSubject()
            self.service = ProjectEventService(subject: self.eventSubject)
        }

        describe("Creating climbs") {
            context("When the service creates a climb") {
                it("Then a single climb created event is published") {
                    let recorder = self.eventSubject.record(),
                        grade = HuecoGrade.easy

                    self.service.create(BoulderAttempt.self, grade: grade)

                    let publishedEvent: EventEnvelope<ProjectEvent> =
                        try self.wait(for: recorder.next(), timeout: 2.0)

                    if case .created(let climb) = publishedEvent.event {
                        let actualClimb = climb as! Project<BoulderAttempt<HuecoGrade>>
                        XCTAssertEqual(actualClimb.grade, grade)
                        // FIXME: inject current time for testing
                        // XCTAssertEqual(actualClimb.createdAt, climbedAt)
                    } else {
                        XCTFail("Unexpected case: \(publishedEvent)")
                    }
                }
            }
        }
    }
}
