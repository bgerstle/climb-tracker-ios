//
//  ClimbHistoryViewModelTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 7/11/21.
//

import XCTest
import Quick
import Combine
import CombineExpectations
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
                    let expectedClimbAttributes = Climb.Attributes(
                            climbedAt: Date(),
                            grade: BoulderGrade.easy,
                            category: BoulderCategory.self
                        ),
                        eventEnvelope = Climb.create(attributes: expectedClimbAttributes),
                        recorder = self.viewModel.$createdClimbs.dropFirst().record()

                    self.viewModel.handleClimbEvents(self.eventSubject).store(in: &self.cancellables)
                    self.eventSubject.send(eventEnvelope)

                    let actualClimbList = try self.wait(for: recorder.next(), timeout: 2.0)

                    XCTAssertEqual(actualClimbList.count, 1)
                    XCTAssertEqual(actualClimbList.first?.attributes, expectedClimbAttributes)
                }
            }

            context("When multiple climb created events are published") {
                it("Then it publishes the new climb lists as elements are added") {
                    let expectedClimbAttributes1 = Climb.Attributes(
                        climbedAt: Date(),
                        grade: BoulderGrade.easy,
                        category: BoulderCategory.self
                    ),
                        expectedClimbAttributes2 = Climb.Attributes(
                            climbedAt: Date().addingTimeInterval(1.0),
                            grade: BoulderGrade.five,
                            category: BoulderCategory.self
                        ),
                        eventEnvelope1 = Climb.create(attributes: expectedClimbAttributes1),
                        eventEnvelope2 = Climb.create(attributes: expectedClimbAttributes2),
                        recorder = self.viewModel.$createdClimbs.dropFirst().record()
                    self.viewModel.handleClimbEvents(self.eventSubject).store(in: &self.cancellables)


                    self.eventSubject.send(eventEnvelope1)
                    self.eventSubject.send(eventEnvelope2)

                    let actualClimbLists = try self.wait(for: recorder.next(2), timeout: 2.0)

                    XCTAssertEqual(actualClimbLists.count, 2)

                    let firstList = actualClimbLists[0]
                    XCTAssertEqual(firstList.first?.attributes, expectedClimbAttributes1)

                    let secondList = actualClimbLists[1]
                    XCTAssertEqual(secondList.first?.attributes, expectedClimbAttributes2)
                    XCTAssertEqual(secondList[1].attributes, expectedClimbAttributes1)
                }
            }
        }
    }
}
