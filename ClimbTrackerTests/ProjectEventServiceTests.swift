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
                        climbedAt = Date(),
                        grade = HuecoGrade.easy

                    self.service.create(climbedAt: climbedAt,
                                        grade: grade,
                                        category: BoulderCategory.self)

                    let publishedEvent: EventEnvelope<ProjectEvent> =
                        try self.wait(for: recorder.next(), timeout: 2.0)

                    if case .created(let climb) = publishedEvent.event {
                        let actualClimb = climb as! Project<BoulderCategory>
                        XCTAssertEqual(actualClimb.systemicGrade, grade)
                        XCTAssertEqual(actualClimb.createdAt, climbedAt)
                    } else {
                        XCTFail("Unexpected case: \(publishedEvent)")
                    }
                }
            }
        }
    }
}
