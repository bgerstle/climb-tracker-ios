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

class ClimbServiceTests: QuickSpec {
    typealias TestClimbEventSubject = PassthroughSubject<EventEnvelope<ClimbEvent>, Never>
    var eventSubject: TestClimbEventSubject! = nil
    var service: ClimbEventService<TestClimbEventSubject>! = nil

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.eventSubject = TestClimbEventSubject()
            self.service = ClimbEventService(subject: self.eventSubject)
        }

        describe("Creating climbs") {
            context("When the service creates a climb") {
                it("Then a single climb created event is published") {
                    let recorder = self.eventSubject.record(),
                        climbedAt = Date(),
                        grade = BoulderGrade.easy

                    self.service.create(climbedAt: climbedAt,
                                        grade: grade,
                                        category: BoulderCategory.self)

                    let publishedEvent: EventEnvelope<ClimbEvent> =
                        try self.wait(for: recorder.next(), timeout: 2.0)

                    if case .created(let climb) = publishedEvent.event {
                        let actualClimb = climb as! Climb<BoulderCategory>
                        XCTAssertEqual(actualClimb.systemicGrade, grade)
                        XCTAssertEqual(actualClimb.climbedAt, climbedAt)
                    } else {
                        XCTFail("Unexpected case: \(publishedEvent)")
                    }
                }
            }
        }
    }
}
