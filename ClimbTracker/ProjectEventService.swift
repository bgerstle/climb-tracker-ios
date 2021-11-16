//
//  ClimbService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

protocol ProjectService {
    func create<G: BoulderGrade>(grade: G, name: String?) async throws

    func attempt(projectId: UUID, at: Date, didSend: Bool) async throws

    func create<G: RopeGrade>(grade: G, name: String?) async throws

    func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory) async throws
}

extension ProjectService {
    func create<G: RopeGrade>(grade: G) async throws {
        try await create(grade: grade, name: nil)
    }

    func create<G: BoulderGrade>(grade: G) async throws {
        try await create(grade: grade, name: nil)
    }
}

struct ProjectNotFound : Error {
    let id: UUID
}

class ProjectEventService : ProjectService {
    private let eventStore: EventStore

    internal init(eventStore: EventStore) {
        self.eventStore = eventStore
    }

    func create<G: BoulderGrade>(grade: G, name: String?) async throws {
        let projectId = UUID(),
            envelope = EventEnvelope(
            event: BoulderProject.Event.created(BoulderProject.Created(projectId: projectId,
                                                                       createdAt: Date(),
                                                                       grade: grade.any)),
            timestamp: Date())

        let topic = try await eventStore.createTopic(id: projectId.uuidString,
                                                     eventType: BoulderProject.Event.self)
        try await topic.write(envelope)
    }

    func attempt(projectId: UUID, at: Date, didSend: Bool) async throws {
        let envelope = EventEnvelope(
            event: BoulderProject.Event.attempted(BoulderProject.Attempted(
                projectId: projectId,
                attemptId: UUID(),
                didSend: didSend,
                attemptedAt: at)),
            timestamp: Date())

        guard let topic = try await eventStore.findTopic(id: projectId.uuidString,
                                                         eventType: BoulderProject.Event.self) else {
            throw ProjectNotFound(id: projectId)
        }
        try await topic.write(envelope)
    }

    func create<G: RopeGrade>(grade: G, name: String?) async throws {
        let projectId = UUID(),
        envelope = EventEnvelope(
            event: RopeProject.Event.created(RopeProject.Created(projectId: projectId,
                                                                 createdAt: Date(),
                                                                 grade: grade.any)),
            timestamp: Date())

        let topic = try await eventStore.createTopic(id: projectId.uuidString,
                                                     eventType: RopeProject.Event.self)
        try await topic.write(envelope)
    }

    func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory) async throws {
        let envelope = EventEnvelope(
            event: RopeProject.Event.attempted(RopeProject.Attempted(
                projectId: projectId,
                attemptId: UUID(),
                didSend: didSend,
                attemptedAt: at,
                subcategory: subcategory)),
            timestamp: Date())

        guard let topic = try await eventStore.findTopic(id: projectId.uuidString,
                                                         eventType: RopeProject.Event.self) else {
            throw ProjectNotFound(id: projectId)
        }
        try await topic.write(envelope)
    }
}
