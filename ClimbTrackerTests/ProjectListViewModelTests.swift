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

class ProjectListViewModelTests: QuickSpec {
    typealias TestProjectEventSubject = PassthroughSubject<EventEnvelope<ProjectEvent>, Never>
    var eventSubject: TestProjectEventSubject! = nil
    var viewModel: ProjectListViewModel! = nil
    var cancellables: [AnyCancellable] = []

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.eventSubject = TestProjectEventSubject()
            self.cancellables = []
            self.viewModel = ProjectListViewModel()
        }

        afterEach {
            self.cancellables.forEach { $0.cancel() }
        }

        describe("Handling climb created events") {
            context("When a climb created event is published") {
                it("Then it publishes the new climb list with one element") {
                    let climb = Project<BoulderAttempt>(
                            id: UUID(),
                            createdAt: Date(),
                            grade: HuecoGrade.easy,
                            climbs: []
                        ),
                        eventEnvelope = EventEnvelope(event: ProjectEvent.created(climb), timestamp: Date()),
                        recorder = self.viewModel.$projects.dropFirst().record()

                    self.viewModel.handleClimbEvents(self.eventSubject).store(in: &self.cancellables)
                    self.eventSubject.send(eventEnvelope)

                    let actualClimbList = try self.wait(for: recorder.next(), timeout: 2.0)

                    XCTAssertEqual(actualClimbList.count, 1)
                    XCTAssertEqual(actualClimbList.first!.id, climb.id)
                }
            }

            context("When multiple climb created events are published") {
                it("Then it publishes the new climb lists as elements are added") {
                    let expectedClimb1 = Project<BoulderAttempt>(
                            id: UUID(),
                            createdAt: Date(),
                            grade: HuecoGrade.easy,
                            climbs: []
                        ),
                        expectedClimb2 = Project<BoulderAttempt>(
                            id: UUID(),
                            createdAt: Date().addingTimeInterval(1.0),
                            grade: HuecoGrade.five,
                            climbs: []
                        ),
                    eventEnvelope1 = EventEnvelope(event: ProjectEvent.created(expectedClimb1), timestamp: Date()),
                        eventEnvelope2 = EventEnvelope(event: ProjectEvent.created(expectedClimb2), timestamp: Date()),
                        recorder = self.viewModel.$projects.dropFirst().record()
                    self.viewModel.handleClimbEvents(self.eventSubject).store(in: &self.cancellables)


                    self.eventSubject.send(eventEnvelope1)
                    self.eventSubject.send(eventEnvelope2)

                    let actualClimbLists = try self.wait(for: recorder.next(2), timeout: 2.0)

                    XCTAssertEqual(actualClimbLists.count, 2)

                    let firstList = actualClimbLists[0]
                    XCTAssertEqual(firstList.first!.id, expectedClimb1.id)

                    let secondList = actualClimbLists[1]
                    XCTAssertEqual(secondList.first!.id, expectedClimb2.id)
                    XCTAssertEqual(secondList[1].id, expectedClimb1.id)
                }
            }
        }
    }
}
