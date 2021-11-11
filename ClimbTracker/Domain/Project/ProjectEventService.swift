//
//  ClimbService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

protocol RopeProjectService {
    func create<G: RopeGrade>(grade: G)

    func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory)
}

protocol BoulderProjectService {
    func create<G: BoulderGrade>(grade: G)

    func attempt(projectId: UUID, at: Date, didSend: Bool)
}

class BoulderProjectEventService<S: Subject> : BoulderProjectService where S.Output == EventEnvelope<BoulderProject.Event> {
    internal init(subject: S) {
        self.subject = subject
    }

    let subject: S

    func create<G: BoulderGrade>(grade: G) {
        let envelope = EventEnvelope(
            event: BoulderProject.Event.created(BoulderProject.Created(id: UUID(),
                                                                       createdAt: Date(),
                                                                       grade: grade.any)),
            timestamp: Date())

        self.subject.send(envelope)
    }

    func attempt(projectId: UUID, at: Date, didSend: Bool) {
        let envelope = EventEnvelope(
            event: BoulderProject.Event.attempted(BoulderProject.Attempted(
                projectId: projectId,
                attemptId: UUID(),
                didSend: didSend)),
            timestamp: Date())

        self.subject.send(envelope)
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
