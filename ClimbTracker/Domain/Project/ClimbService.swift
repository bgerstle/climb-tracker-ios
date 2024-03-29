//
//  ClimbService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

//protocol ClimbService {
//    func create(climb attributes: ClimbAttributes)
//}

class ClimbEventService<S: Subject> : ClimbEventService where S.Output == EventEnvelope<Climb.Event> {
    internal init(subject: S) {
        self.subject = subject
    }

    let subject: S

    func create(climb attributes: ClimbAttributes) {
        let createEvent = Climb.create(attributes: attributes)
        subject.send(createEvent)
    }
}
