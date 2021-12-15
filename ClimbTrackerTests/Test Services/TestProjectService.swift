//
//  TestProjectService.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/29/21.
//

import Foundation
@testable import ClimbTracker
import XCTest

actor TestProjectService : ProjectService {
    nonisolated func subscribeToProject<T: EventSourcedProject>(withType projectType: T.Type, id projectId: ProjectID) -> TopicEventPublisher<T.Event> {
        return [EventEnvelope<T.Event>]().publisher.eraseToAnyPublisher()
    }

    var projects = [ProjectID: AnyProject]()
    var attempts = [ProjectID: [AnyAttempt]]()

    func create<G>(grade: G) async throws -> ProjectID where G : Boulder, G : Grade {
        let projectId = UUID()
        let boulderProject = BoulderProject(BoulderProject.Created(projectId: projectId, createdAt:
                                                                    Date(),
                                                                   grade: grade.any))
        projects[projectId] = boulderProject
        return projectId
    }

    func create<G>(grade: G) async throws -> ProjectID where G : Grade, G : Rope {
        let projectId = UUID()
        let ropeProject = RopeProject(RopeProject.Created(projectId: projectId,
                                                          createdAt:
                                                            Date(),

                                                          grade: grade.any))
        projects[projectId] = ropeProject
        return projectId
    }


    func attempt(projectId: UUID, at: Date, didSend: Bool) async throws -> AttemptID {
        guard let project = projects[projectId] else {
            throw ProjectNotFound(id: projectId)
        }
        XCTAssertEqual(project.category, .boulder)
        let attempt = BoulderProject.Attempt(id: UUID(), didSend: didSend, attemptedAt: at)

        var projectAttempts = attempts[projectId, default: []]
        projectAttempts.append(attempt)
        attempts[projectId] = projectAttempts

        return attempt.id
    }

    func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory) async throws -> AttemptID {
        guard let project = projects[projectId] else {
            throw ProjectNotFound(id: projectId)
        }
        XCTAssertEqual(project.category, .rope)
        let attempt = RopeProject.Attempt(id: UUID(),
                                          didSend: didSend,
                                          subcategory: subcategory,
                                          attemptedAt: at)

        var projectAttempts = attempts[projectId, default: []]
        projectAttempts.append(attempt)
        attempts[projectId] = projectAttempts

        return attempt.id
    }
}
