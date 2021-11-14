//
//  ClimbService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

protocol RopeProjectService {
    func create<G: RopeGrade>(grade: G) //async throws

    func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory) // async throws
}

protocol BoulderProjectService {
    func create<G: BoulderGrade>(grade: G) async throws

    func attempt(projectId: UUID, at: Date, didSend: Bool) async throws
}

struct ProjectNotFound : Error {
    let id: UUID
}

class BoulderProjectEventService : BoulderProjectService {
    let eventStore: EventStore

    internal init(eventStore: EventStore) {
        self.eventStore = eventStore
    }

    func create<G: BoulderGrade>(grade: G) async throws {
        let projectId = UUID(),
            envelope = EventEnvelope(
            event: BoulderProject.Event.created(BoulderProject.Created(id: projectId,
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
                didSend: didSend)),
            timestamp: Date())

        guard let topic = try await eventStore.findTopic(id: projectId.uuidString,
                                                         eventType: BoulderProject.Event.self) else {
            throw ProjectNotFound(id: projectId)
        }
        try await topic.write(envelope)
    }
}

class RopeProjectEventService<S: Subject> : RopeProjectService where S.Output == EventEnvelope<RopeProject.Event> {
    internal init(subject: S) {
        self.subject = subject
    }

    let subject: S

    func create<G: RopeGrade>(grade: G) {
        let envelope = EventEnvelope(
            event: RopeProject.Event.created(RopeProject.Created(id: UUID(),
                                                                 createdAt: Date(),
                                                                 grade: grade.any)),
            timestamp: Date())

        self.subject.send(envelope)
    }

    func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory) {
        let envelope = EventEnvelope(
            event: RopeProject.Event.attempted(RopeProject.Attempted(
                projectId: projectId,
                attemptId: UUID(),
                didSend: didSend,
                subcategory: subcategory)),
            timestamp: Date())

        self.subject.send(envelope)
    }
}
