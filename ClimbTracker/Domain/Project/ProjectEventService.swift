//
//  ClimbService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

protocol ProjectService {
    // Need to add climbType to fn signature, otherwise compiler complains that C isn't used.
    // Could also return Project<C>, but that requires callers to assign the return value to a variable
    // with a type annotation, which is tedious.
    func create<C: ClimbType>(_ climbType: C.Type, grade: C.GradeType)
}

class ProjectEventService<S: Subject> : ProjectService where S.Output == EventEnvelope<ProjectEvent> {
    internal init(subject: S) {
        self.subject = subject
    }

    let subject: S

    func create<C: ClimbType>(_ climbType: C.Type, grade: C.GradeType) {
        let project = Project<C>(id: UUID(), createdAt: Date(), grade: grade, climbs: []),
            event = EventEnvelope(
            event: ProjectEvent.created(project),
            timestamp: Date()
        )
        subject.send(event)
    }
}
