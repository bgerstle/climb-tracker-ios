//
//  ClimbHistoryViewModelTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 7/11/21.
//

import XCTest
import Quick
import Combine
@testable import ClimbTracker

class ClimbHistoryViewModelTests: QuickSpec {
    typealias TestClimbEventSubject = PassthroughSubject<EventEnvelope<Climb.Event>, Never>
    var eventSubject: TestClimbEventSubject! = nil
    var viewModel: ClimbHistoryViewModel! = nil
    var cancellables: [AnyCancellable] = []

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.eventSubject = TestClimbEventSubject()
            self.cancellables = []
            self.viewModel = ClimbHistoryViewModel()
        }

        afterEach {
            self.cancellables.forEach { $0.cancel() }
        }

        describe("Handling climb created events") {
            context("When a climb created event is published") {
                it("Then it publishes the new climb list with one element") {
                    let expectedClimbAttributes = ClimbAttributes(
                            climbedAt: Date(),
                            kind: .boulder(grade: .easy)
                        ),
                        eventEnvelope = Climb.create(attributes: expectedClimbAttributes)
                    var actualClimbList: [Climb]!
                    let expectation = self.expectation(description: "published new list")
                    self.viewModel.$createdClimbs.dropFirst().sink {
                        actualClimbList = $0
                        expectation.fulfill()
                    }.store(in: &self.cancellables)

                    self.viewModel.handleClimbEvents(self.eventSubject).store(in: &self.cancellables)
                    self.eventSubject.send(eventEnvelope)

                    self.waitForExpectations(timeout: 2.0) { error in
                        XCTAssertNil(error)
                    }
                    guard actualClimbList != nil else { return }

                    XCTAssertEqual(actualClimbList.count, 1)
                    XCTAssertEqual(actualClimbList.first?.attributes, expectedClimbAttributes)
                }
            }
        }
    }
}
