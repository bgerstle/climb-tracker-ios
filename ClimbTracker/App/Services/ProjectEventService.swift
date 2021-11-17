//
//  ProjectEventService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/17/21.
//

import Foundation
import Combine

struct ProjectNotFound : Error {
    let id: UUID
}

class ProjectEventService : ProjectService {
    private let eventStore: EventStore

    internal init(eventStore: EventStore) {
        self.eventStore = eventStore
    }

    var boulderProjectEventPublisher: TopicEventPublisher<BoulderProject.Event> {
        eventStore.namespaceEvents()
    }

    var ropeProjectEventPublisher: TopicEventPublisher<RopeProject.Event> {
        eventStore.namespaceEvents()
    }

    func create<G: BoulderGrade>(grade: G) async throws -> ProjectID {
        let projectId = UUID(),
            envelope = EventEnvelope(
            event: BoulderProject.Event.created(BoulderProject.Created(projectId: projectId,
                                                                       createdAt: Date(),
                                                                       grade: grade.any)),
            timestamp: Date())

        let topic = try await eventStore.createTopic(id: projectId.uuidString,
                                                     eventType: BoulderProject.Event.self)
        try await topic.write(envelope)

        return projectId
    }

    func attempt(projectId: UUID, at: Date, didSend: Bool) async throws -> AttemptID {
        let attemptId = UUID(),
            envelope = EventEnvelope(
            event: BoulderProject.Event.attempted(BoulderProject.Attempted(
                projectId: projectId,
                attemptId: attemptId,
                didSend: didSend,
                attemptedAt: at)),
            timestamp: Date())

        guard let topic = try await eventStore.findTopic(id: projectId.uuidString,
                                                         eventType: BoulderProject.Event.self) else {
            throw ProjectNotFound(id: projectId)
        }
        try await topic.write(envelope)

        return attemptId
    }

    func create<G: RopeGrade>(grade: G) async throws -> ProjectID {
        let projectId = UUID(),
        envelope = EventEnvelope(
            event: RopeProject.Event.created(RopeProject.Created(projectId: projectId,
                                                                 createdAt: Date(),
                                                                 grade: grade.any)),
            timestamp: Date())

        let topic = try await eventStore.createTopic(id: projectId.uuidString,
                                                     eventType: RopeProject.Event.self)
        try await topic.write(envelope)

        return projectId
    }

    func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory) async throws -> AttemptID {
        let attemptId = UUID(),
            envelope = EventEnvelope(
            event: RopeProject.Event.attempted(RopeProject.Attempted(
                projectId: projectId,
                attemptId: attemptId,
                didSend: didSend,
                attemptedAt: at,
                subcategory: subcategory)),
            timestamp: Date())

        guard let topic = try await eventStore.findTopic(id: projectId.uuidString,
                                                         eventType: RopeProject.Event.self) else {
            throw ProjectNotFound(id: projectId)
        }

        try await topic.write(envelope)

        return attemptId
    }
}
