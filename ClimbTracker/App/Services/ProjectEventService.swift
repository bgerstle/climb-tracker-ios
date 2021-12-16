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
            event: BoulderProject.Event.created(BoulderProject.Event.Created(projectId: projectId,
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
            event: BoulderProject.Event.attempted(BoulderProject.Event.Attempted(
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
            event: RopeProject.Event.created(RopeProject.Event.Created(projectId: projectId,
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
            event: RopeProject.Event.attempted(RopeProject.Event.Attempted(
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

    func subscribeToProject<T>(withType projectType: T.Type, id projectId: ProjectID) -> TopicEventPublisher<T.Event> where T : EventSourcedProject {
        Future<TopicEventPublisher<T.Event>, Error> { promise in
            Task {
                do {
                    guard let topic = try await self.eventStore.findTopic(
                        id: projectId.uuidString,
                        eventType: projectType.Event.self
                    ) else {
                        throw ProjectNotFound(id: projectId)
                    }
                    promise(.success(topic.eventPublisher))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .assertNoFailure()
        .flatMap { $0 }
        .eraseToAnyPublisher()
    }

    func updateAttempt(projectId: ProjectID, attemptId: AttemptID, didSend: Bool, attemptedAt: Date) async throws {
        guard let topic = try await eventStore.findTopic(id: projectId.uuidString,
                                                         eventType: BoulderProject.Event.self) else {
            throw ProjectNotFound(id: projectId)
        }

        let payload = BoulderProject.Event.AttemptUpdated(
            projectId: projectId,
            attemptId: attemptId,
            didSend: didSend,
            attemptedAt: attemptedAt
        )

        try await topic.write(EventEnvelope(event: .attemptUpdated(payload), timestamp: Date()))
    }

    func updateAttempt(projectId: ProjectID, attemptId: AttemptID, didSend: Bool, attemptedAt: Date, subcategory: RopeProject.Subcategory) async throws {
        guard let topic = try await eventStore.findTopic(id: projectId.uuidString,
                                                         eventType: RopeProject.Event.self) else {
            throw ProjectNotFound(id: projectId)
        }

        let payload = RopeProject.Event.AttemptUpdated(
            projectId: projectId,
            attemptId: attemptId,
            didSend: didSend,
            attemptedAt: attemptedAt,
            subcategory: subcategory
        )

        try await topic.write(EventEnvelope(event: .attemptUpdated(payload), timestamp: Date()))
    }
}
