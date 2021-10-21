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
    typealias TestClimbEventSubject = PassthroughSubject<EventEnvelope<ClimbEvent>, Never>
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
                    let climb = Climb<BoulderCategory>(
                            id: UUID(),
                            climbedAt: Date(),
                            grade: BoulderGrade.easy
                        ),
                        eventEnvelope = EventEnvelope(event: ClimbEvent.created(climb), timestamp: Date()),
                        recorder = self.viewModel.$createdClimbs.dropFirst().record()

                    self.viewModel.handleClimbEvents(self.eventSubject).store(in: &self.cancellables)
                    self.eventSubject.send(eventEnvelope)

                    let actualClimbList = try self.wait(for: recorder.next(), timeout: 2.0)

                    XCTAssertEqual(actualClimbList.count, 1)
                    XCTAssertEqual(actualClimbList.first as! Climb<BoulderCategory>, climb)
                }
            }

            context("When multiple climb created events are published") {
                it("Then it publishes the new climb lists as elements are added") {
                    let expectedClimb1 = Climb<BoulderCategory>(
                            id: UUID(),
                            climbedAt: Date(),
                            grade: BoulderGrade.easy
                        ),
                        expectedClimb2 = Climb<BoulderCategory>(
                            id: UUID(),
                            climbedAt: Date().addingTimeInterval(1.0),
                            grade: BoulderGrade.five
                        ),
                    eventEnvelope1 = EventEnvelope(event: ClimbEvent.created(expectedClimb1), timestamp: Date()),
                        eventEnvelope2 = EventEnvelope(event: ClimbEvent.created(expectedClimb2), timestamp: Date()),
                        recorder = self.viewModel.$createdClimbs.dropFirst().record()
                    self.viewModel.handleClimbEvents(self.eventSubject).store(in: &self.cancellables)


                    self.eventSubject.send(eventEnvelope1)
                    self.eventSubject.send(eventEnvelope2)

                    let actualClimbLists = try self.wait(for: recorder.next(2), timeout: 2.0)

                    XCTAssertEqual(actualClimbLists.count, 2)

                    let firstList = actualClimbLists[0]
                    XCTAssertEqual(firstList.first as! Climb<BoulderCategory>, expectedClimb1)

                    let secondList = actualClimbLists[1]
                    XCTAssertEqual(secondList.first as! Climb<BoulderCategory>, expectedClimb2)
                    XCTAssertEqual(secondList[1] as! Climb<BoulderCategory>, expectedClimb1)
                }
            }
        }
    }
}
