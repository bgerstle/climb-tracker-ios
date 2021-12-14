//
//  ProjectListViewModelTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 7/11/21.
//

import XCTest
import Combine
import CombineExpectations
@testable import ClimbTracker

@MainActor
class ProjectListViewModelTests: XCTestCase {
    typealias TestProjectSummaryEventSubject = PassthroughSubject<EventEnvelope<ProjectSummary.Event>, Never>
    var eventSubject: TestProjectSummaryEventSubject! = nil
    var viewModel: ProjectListViewModel! = nil
    var testProjectService: TestProjectService! = nil

    override func setUp() async throws {
        await isolatedSetUp()
    }

    func isolatedSetUp() {
        self.continueAfterFailure = false
        self.eventSubject = TestProjectSummaryEventSubject()
        self.testProjectService = TestProjectService()
        self.viewModel = ProjectListViewModel(projectService: self.testProjectService)
    }

    func testHandleEvent_WhenSummaryCreated_ThenSummaryAddedToList() throws {
        let payload = ProjectSummary.Event.Created(
                id: UUID(),
                createdAt: Date(),
                grade: HuecoGrade.four.rawValue,
                category: .boulder
            ),
            event = ProjectSummary.Event.created(payload),
            eventEnvelope = EventEnvelope(event: event, timestamp: Date()),
            projectListRecorder = viewModel.$projects.dropFirst().record()

        viewModel.handle(eventEnvelope)

        let actualClimbList = try wait(for: projectListRecorder.next(), timeout: 2.0)

        XCTAssertEqual(actualClimbList.count, 1)
        guard let actualSummary = actualClimbList.first else { XCTFail(); return }

        XCTAssertEqual(actualSummary.id, payload.id)
        XCTAssertEqual(actualSummary.category, payload.category)
        XCTAssertEqual(actualSummary.grade, payload.grade)
        XCTAssertEqual(actualSummary.attemptCount, 0)
        XCTAssertEqual(actualSummary.sendCount, 0)
        XCTAssertEqual(actualSummary.sessionDates, Set())
        XCTAssertNil(actualSummary.name)
        // TODO: title
    }

    func testHandleEvent_WhenSummaryCreatedAndNamed_ThenSummaryAddedToListAndUpdatedWithName() throws {
        let createdPayload = ProjectSummary.Event.Created(
                id: UUID(),
                createdAt: Date(),
                grade: HuecoGrade.four.rawValue,
                category: .boulder
            ),
            namedPayload = ProjectSummary.Event.Named(projectId: createdPayload.id, name: "foo"),
            // ignore initially empty list
            projectListRecorder = viewModel.$projects.dropFirst().record()

        viewModel.handle(EventEnvelope(event: .created(createdPayload),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .named(namedPayload),
                                       timestamp: Date()))

        guard let finalClimbList = try wait(for: projectListRecorder.next(2), timeout: 2.0).last else {
            XCTFail(); return
        }

        XCTAssertEqual(finalClimbList.count, 1)
        guard let actualSummary = finalClimbList.first else { XCTFail(); return }

        XCTAssertEqual(actualSummary.id, createdPayload.id)
        XCTAssertEqual(actualSummary.category, createdPayload.category)
        XCTAssertEqual(actualSummary.grade, createdPayload.grade)
        XCTAssertEqual(actualSummary.attemptCount, 0)
        XCTAssertEqual(actualSummary.sendCount, 0)
        XCTAssertEqual(actualSummary.sessionDates, Set())
        XCTAssertEqual(actualSummary.name, namedPayload.name)
    }

    func testHandleEvent_WhenSummaryNamedAndCreated_ThenSummaryAddedToListWithName() throws {
        let createdPayload = ProjectSummary.Event.Created(
                id: UUID(),
                createdAt: Date(),
                grade: HuecoGrade.four.rawValue,
                category: .boulder
            ),
            namedPayload = ProjectSummary.Event.Named(projectId: createdPayload.id, name: "foo"),
            // ignore initially empty list
            projectListRecorder = viewModel.$projects.dropFirst().record()

        viewModel.handle(EventEnvelope(event: .named(namedPayload),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .created(createdPayload),
                                       timestamp: Date()))

        let finalClimbList = try wait(for: projectListRecorder.next(), timeout: 2.0)

        XCTAssertEqual(finalClimbList.count, 1)
        guard let actualSummary = finalClimbList.first else { XCTFail(); return }

        XCTAssertEqual(actualSummary.id, createdPayload.id)
        XCTAssertEqual(actualSummary.category, createdPayload.category)
        XCTAssertEqual(actualSummary.grade, createdPayload.grade)
        XCTAssertEqual(actualSummary.attemptCount, 0)
        XCTAssertEqual(actualSummary.sendCount, 0)
        XCTAssertEqual(actualSummary.sessionDates, Set())
        XCTAssertEqual(actualSummary.name, namedPayload.name)
    }

    func testHandleEvent_WhenSummaryCreatedAndAttempted_ThenSummaryUpdatedWithAttempt() throws {
        let createdPayload = ProjectSummary.Event.Created(
                id: UUID(),
                createdAt: Date(),
                grade: HuecoGrade.four.rawValue,
                category: .boulder
            ),
            attemptedPayload = ProjectSummary.Event.Attempted(projectId: createdPayload.id,
                                                              didSend: false,
                                                              attemptedAt: Date()),
            // ignore initially empty list
            projectListRecorder = viewModel.$projects.dropFirst().record()

        viewModel.handle(EventEnvelope(event: .created(createdPayload),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .attempted(attemptedPayload),
                                       timestamp: Date()))

        // publishes list w/ created project, then "updated" list w/ attempted project
        let publishedLists = try wait(for: projectListRecorder.next(2), timeout: 2.0)

        guard let finalClimbList = publishedLists.last else { XCTFail(); return }

        XCTAssertEqual(finalClimbList.count, 1)
        guard let actualSummary = finalClimbList.first else { XCTFail(); return }

        XCTAssertEqual(actualSummary.id, createdPayload.id)
        XCTAssertEqual(actualSummary.category, createdPayload.category)
        XCTAssertEqual(actualSummary.grade, createdPayload.grade)
        XCTAssertEqual(actualSummary.attemptCount, 1)
        XCTAssertEqual(actualSummary.sendCount, 0)
        XCTAssertEqual(actualSummary.sessionDates, Set([Calendar.defaultClimbCalendar.startOfDay(for: attemptedPayload.attemptedAt)]))
    }

    func testHandleEvent_GivenTwoProjects_WhenOneAttempted_ThenCorrectSummaryUpdated() throws {
        let createdPayload1 = ProjectSummary.Event.Created(
                id: UUID(),
                createdAt: Date(),
                grade: HuecoGrade.four.rawValue,
                category: .boulder
            ),
            createdPayload2 = ProjectSummary.Event.Created(
                    id: UUID(),
                    createdAt: Date(),
                    grade: YosemiteDecimalGrade.tenA.rawValue,
                    category: .rope
                ),
            attemptedPayload = ProjectSummary.Event.Attempted(projectId: createdPayload1.id, didSend: true, attemptedAt: Date()),
            // ignore initially empty list
            projectListRecorder = viewModel.$projects.dropFirst().record()

        viewModel.handle(EventEnvelope(event: .created(createdPayload1),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .created(createdPayload2),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .attempted(attemptedPayload),
                                       timestamp: Date()))

        // publishes list w/ created project, then "updated" list w/ attempted project
        let publishedLists = try wait(for: projectListRecorder.next(3), timeout: 2.0)

        guard let finalClimbList = publishedLists.last else { XCTFail(); return }

        XCTAssertEqual(finalClimbList.count, 2)
        guard let attemptedSummary = finalClimbList.first(where: { $0.id == attemptedPayload.projectId }) else {
            XCTFail(); return
        }

        XCTAssertEqual(attemptedSummary.id, attemptedPayload.projectId)
        XCTAssertEqual(attemptedSummary.id, createdPayload1.id)
        XCTAssertEqual(attemptedSummary.category, createdPayload1.category)
        XCTAssertEqual(attemptedSummary.grade, createdPayload1.grade)
        XCTAssertEqual(attemptedSummary.attemptCount, 1)
        XCTAssertEqual(attemptedSummary.sendCount, 1)
        XCTAssertEqual(attemptedSummary.sessionDates.count, 1)

        guard let unattemptedSummary = finalClimbList.first(where: { $0.id != attemptedPayload.projectId }) else {
            XCTFail(); return
        }

        XCTAssertNotEqual(unattemptedSummary.id, attemptedPayload.projectId)
        XCTAssertEqual(unattemptedSummary.id, createdPayload2.id)
        XCTAssertEqual(unattemptedSummary.category, createdPayload2.category)
        XCTAssertEqual(unattemptedSummary.grade, createdPayload2.grade)
        XCTAssertEqual(unattemptedSummary.attemptCount, 0)
        XCTAssertEqual(unattemptedSummary.sendCount, 0)
        XCTAssertEqual(unattemptedSummary.sessionDates.count, 0)
    }

    func testHandleEvent_GivenNamedAndUnnamedProjects_WhenAttempted_CorrectSummariesUpdated() throws {
        let createdPayload1 = ProjectSummary.Event.Created(
                id: UUID(),
                createdAt: Date(),
                grade: HuecoGrade.four.rawValue,
                category: .boulder
            ),
            createdPayload2 = ProjectSummary.Event.Created(
                    id: UUID(),
                    createdAt: Date(),
                    grade: YosemiteDecimalGrade.tenA.rawValue,
                    category: .rope
            ),
            namedProject2 = ProjectSummary.Event.Named(
                projectId: createdPayload2.id,
                name: "foo"
            ),
            attemptedProject1 = ProjectSummary.Event.Attempted(projectId: createdPayload1.id, didSend: false, attemptedAt: Date()),
            attemptedProject2 = ProjectSummary.Event.Attempted(projectId: createdPayload2.id, didSend: true, attemptedAt: Date()),
            // ignore initially empty list
            projectListRecorder = viewModel.$projects.dropFirst().record()

        viewModel.handle(EventEnvelope(event: .created(createdPayload1),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .named(namedProject2),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .created(createdPayload2),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .attempted(attemptedProject2),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .attempted(attemptedProject1),
                                       timestamp: Date()))

        // publishes list w/ created project, then "updated" list w/ attempted project
        let publishedLists = try wait(for: projectListRecorder.availableElements, timeout: 2.0)
        XCTAssertEqual(publishedLists.count, 4)

        guard let finalClimbList = publishedLists.last else { XCTFail(); return }

        XCTAssertEqual(finalClimbList.count, 2)
        guard let project1Summary = finalClimbList.first(where: { $0.id == createdPayload1.id }) else {
            XCTFail(); return
        }

        XCTAssertEqual(project1Summary.category, createdPayload1.category)
        XCTAssertEqual(project1Summary.grade, createdPayload1.grade)
        XCTAssertEqual(project1Summary.attemptCount, 1)
        XCTAssertEqual(project1Summary.sendCount, 0)
        XCTAssertEqual(project1Summary.sessionDates.count, 1)

        guard let project2Summary = finalClimbList.first(where: { $0.id == createdPayload2.id }) else {
            XCTFail(); return
        }

        XCTAssertEqual(project2Summary.category, createdPayload2.category)
        XCTAssertEqual(project2Summary.grade, createdPayload2.grade)
        XCTAssertEqual(project2Summary.sendCount, 1)
        XCTAssertEqual(project2Summary.sessionDates.count, 1)
    }

    // TODO: separate concern for session date aggregation
    func testHandleEvent_WhenSummaryCreatedAndAttemptedInMultipleSessions_ThenSummaryHasTwoSessionDates() throws {
        let createdPayload = ProjectSummary.Event.Created(
                id: UUID(),
                createdAt: Date(),
                grade: HuecoGrade.four.rawValue,
                category: .boulder
            ),
            sessionDate1Components = Calendar.defaultClimbCalendar.components(
                withYear: 2021,
                month: 01,
                day: 01),
            sessionDate2Components = Calendar.defaultClimbCalendar.components(
                withYear: sessionDate1Components.year!,
                month: sessionDate1Components.month!,
                day: sessionDate1Components.day! + 1),
            // add seconds so not exactly at start of day
            sessionDate1 = sessionDate1Components.date!.advanced(by: 60),
            sessionDate2 = sessionDate2Components.date!.advanced(by: 65),
            attemptedPayload1 = ProjectSummary.Event.Attempted(
                projectId: createdPayload.id,
                didSend: false,
                attemptedAt: sessionDate1),
            attemptedPayload2 = ProjectSummary.Event.Attempted(
                projectId: createdPayload.id,
                didSend: true,
                attemptedAt: sessionDate2),
            // ignore initially empty list
            projectListRecorder = viewModel.$projects.dropFirst().record()

        viewModel.handle(EventEnvelope(event: .created(createdPayload),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .attempted(attemptedPayload1),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .attempted(attemptedPayload2),
                                       timestamp: Date()))

        // publishes list w/ created project, then "updated" list w/ attempted project
        let publishedLists = try wait(for: projectListRecorder.next(3), timeout: 2.0)

        guard let finalClimbList = publishedLists.last else { XCTFail(); return }

        XCTAssertEqual(finalClimbList.count, 1)
        guard let actualSummary = finalClimbList.first else { XCTFail(); return }

        XCTAssertEqual(actualSummary.id, createdPayload.id)
        XCTAssertEqual(actualSummary.category, createdPayload.category)
        XCTAssertEqual(actualSummary.grade, createdPayload.grade)
        XCTAssertEqual(actualSummary.attemptCount, 2)
        XCTAssertEqual(actualSummary.sendCount, 1)
        XCTAssertEqual(actualSummary.sessionDates,
                       Set([sessionDate1Components.date!, sessionDate2Components.date!]))
    }

    func testHandleEvent_SortsListByLastAttemptDateDesc() throws {
        let createdPayload1 = ProjectSummary.Event.Created(
                id: UUID(),
                createdAt: Date(),
                grade: HuecoGrade.four.rawValue,
                category: .boulder
            ),
            createdPayload2 = ProjectSummary.Event.Created(
                    id: UUID(),
                    createdAt: Date(),
                    grade: YosemiteDecimalGrade.tenA.rawValue,
                    category: .rope
            ),
            attemptedProject1 = ProjectSummary.Event.Attempted(
                projectId: createdPayload1.id,
                didSend: false,
                attemptedAt: Date()
            ),
            attemptedProject2 = ProjectSummary.Event.Attempted(
                projectId: createdPayload2.id,
                didSend: true,
                attemptedAt: attemptedProject1.attemptedAt.advanced(by: 1)
            ),
            // ignore initially empty list
            projectListRecorder = viewModel.$projects.dropFirst().record()

        // TODO: verify sorting for arbitrary sequences of created & attempted events
        // for now, handle events in order that previously would have resulted in project2
        // being second in the list (since project1 would have been inserted before it), but
        // now should result in project 2 being first since its last attempt was later
        viewModel.handle(EventEnvelope(event: .created(createdPayload2),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .created(createdPayload1),
                                       timestamp: Date()))

        viewModel.handle(EventEnvelope(event: .attempted(attemptedProject2),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .attempted(attemptedProject1),
                                       timestamp: Date()))

        // publishes list w/ created project, then "updated" list w/ attempted project
        let publishedLists = try wait(for: projectListRecorder.availableElements, timeout: 2.0)
        XCTAssertEqual(publishedLists.count, 4)

        guard let finalClimbList = publishedLists.last else { XCTFail(); return }

        XCTAssertEqual(finalClimbList.count, 2)

        XCTAssertEqual(finalClimbList.map(\.id), [createdPayload2.id, createdPayload1.id])
    }

    func testHandleEvent_SortsListDefaultsToCreatedForUnattemptedProjectsDesc() throws {
        let createdPayload1 = ProjectSummary.Event.Created(
                id: UUID(),
                createdAt: Date(),
                grade: HuecoGrade.four.rawValue,
                category: .boulder
            ),
            createdPayload2 = ProjectSummary.Event.Created(
                    id: UUID(),
                    createdAt: createdPayload1.createdAt.advanced(by: 1),
                    grade: YosemiteDecimalGrade.tenA.rawValue,
                    category: .rope
            ),
            attemptedProject1 = ProjectSummary.Event.Attempted(
                projectId: createdPayload1.id,
                didSend: false,
                attemptedAt: createdPayload2.createdAt.advanced(by: 1)
            ),
            // ignore initially empty list
            projectListRecorder = viewModel.$projects.dropFirst().record()

        // TODO: verify sorting for arbitrary sequences of created & attempted events
        // for now, handle events in order that previously would have resulted in project2
        // being second in the list (since project1 would have been inserted before it), but
        // now should result in project 2 being first since its last attempt was later
        viewModel.handle(EventEnvelope(event: .created(createdPayload2),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .created(createdPayload1),
                                       timestamp: Date()))
        viewModel.handle(EventEnvelope(event: .attempted(attemptedProject1),
                                       timestamp: Date()))

        // publishes list w/ created project, then "updated" list w/ attempted project
        let publishedLists = try wait(for: projectListRecorder.availableElements, timeout: 2.0)
        XCTAssertEqual(publishedLists.count, 3)

        guard let finalClimbList = publishedLists.last else { XCTFail(); return }

        XCTAssertEqual(finalClimbList.count, 2)

        XCTAssertEqual(finalClimbList.map(\.id), [createdPayload1.id, createdPayload2.id])
    }

}
