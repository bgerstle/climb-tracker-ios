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
}

protocol BoulderProjectService {
    func create<G: BoulderGrade>(grade: G)
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
}
