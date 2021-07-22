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
@testable import ClimbTracker

class ClimbServiceTests: QuickSpec {
    typealias TestClimbEventSubject = PassthroughSubject<EventEnvelope<Climb.Event>, Never>
    var eventSubject: TestClimbEventSubject! = nil
    var service: ClimbEventService<TestClimbEventSubject>! = nil
    var cancellables: [AnyCancellable] = []

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.eventSubject = TestClimbEventSubject()
            self.cancellables = []
            self.service = ClimbEventService(subject: self.eventSubject)
        }

        afterEach {
            self.cancellables.forEach { $0.cancel() }
        }

        describe("Creating climbs") {
            context("When the service creates a climb") {
                it("Then a single climb created event is published") {
                    var publishedEvent: EventEnvelope<Climb.Event>! = nil
                    let expectation = self.expectation(description: "publish event")
                    self.eventSubject
                        .sink {
                            publishedEvent = $0
                            expectation.fulfill()
                        }
                        .store(in: &self.cancellables)

                    let expectedClimbAttributes = Climb.Attributes(
                        climbedAt: Date(),
                        grade: BoulderGrade.easy,
                        category: BoulderCategory.self
                    )

                    self.service.create(climb: expectedClimbAttributes)

                    self.waitForExpectations(timeout: 2.0) { error in
                        XCTAssertNil(error)
                    }

                    guard publishedEvent != nil else { return }

                    if case .created(let climb) = publishedEvent.event {
                        XCTAssertEqual(climb.attributes, expectedClimbAttributes)
                    } else {
                        XCTFail("Unexpected case: \(publishedEvent.event)")
                    }
                }
            }
        }
    }
}
