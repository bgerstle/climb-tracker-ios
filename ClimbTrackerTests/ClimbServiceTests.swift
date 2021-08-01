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
    typealias TestClimbEventSubject = PassthroughSubject<EventEnvelope<Climb.Event>, Never>
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
                        expectedClimbAttributes = Climb.Attributes(
                            climbedAt: Date(),
                            grade: BoulderGrade.easy,
                            category: BoulderCategory.self
                        )

                    self.service.create(climb: expectedClimbAttributes)

                    let publishedEvent: EventEnvelope<Climb.Event> =
                        try self.wait(for: recorder.next(), timeout: 2.0)

                    if case .created(let climb) = publishedEvent.event {
                        XCTAssertEqual(climb.attributes, expectedClimbAttributes)
                    } else {
                        XCTFail("Unexpected case: \(publishedEvent)")
                    }
                }
            }
        }
    }
}
