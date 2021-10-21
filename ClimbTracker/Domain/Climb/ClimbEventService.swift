//
//  ClimbService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

protocol ClimbService {
    func create<CT: CategoryType>(climbedAt: Date, grade: CT.GradeType, category: CT.Type)
}

class ClimbEventService<S: Subject> : ClimbService where S.Output == EventEnvelope<ClimbEvent> {
    internal init(subject: S) {
        self.subject = subject
    }

    let subject: S

    func create<CT: CategoryType>(climbedAt: Date, grade: CT.GradeType, category: CT.Type) {
        let climb = Climb<CT>(id: UUID(), climbedAt: climbedAt, grade: grade)
        let event = EventEnvelope(
            event: ClimbEvent.created(climb),
            timestamp: Date()
        )
        subject.send(event)
    }
}
