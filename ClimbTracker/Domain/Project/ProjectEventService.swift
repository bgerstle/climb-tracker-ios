//
//  ClimbService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

protocol ProjectService {
    func create<CT: CategoryType>(climbedAt: Date, grade: CT.GradeType, category: CT.Type)
}

class ProjectEventService<S: Subject> : ProjectService where S.Output == EventEnvelope<ProjectEvent> {
    internal init(subject: S) {
        self.subject = subject
    }

    let subject: S

    func create<CT: CategoryType>(climbedAt: Date, grade: CT.GradeType, category: CT.Type) {
        let climb = Project<CT>(id: UUID(), climbedAt: climbedAt, grade: grade)
        let event = EventEnvelope(
            event: ProjectEvent.created(climb),
            timestamp: Date()
        )
        subject.send(event)
    }
}
