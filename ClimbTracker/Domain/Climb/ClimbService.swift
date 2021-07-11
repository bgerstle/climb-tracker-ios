//
//  ClimbService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

class ClimbService<S: Subject> where S.Output == EventEnvelope<Climb.Event> {
    internal init(subject: S) {
        self.subject = subject
    }

    let subject: S

    func create(climb attributes: ClimbAttributes) {
        let createEvent = Climb.create(attributes: attributes)
        subject.send(createEvent)
    }
}
