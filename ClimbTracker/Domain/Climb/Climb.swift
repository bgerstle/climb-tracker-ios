//
//  Climb.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

class Climb: Identifiable {
    private init(id: UUID, attributes: ClimbAttributes) {
        self.id = id
        self.attributes = attributes
    }

    enum Event {
        case created(climb: Climb)
    }

    let id: UUID

    let attributes: ClimbAttributes

    static func create(attributes: ClimbAttributes) -> EventEnvelope<Event> {
        return EventEnvelope(
            event: .created(climb: Climb(id: UUID(), attributes: attributes)),
            timestamp: Date()
        )
    }
}

struct ClimbAttributes: Hashable, Equatable {
    let climbedAt: Date

    enum Category: Hashable, Equatable {
        case boulder(grade: BoulderGrade)
    }

    let kind: Category
}
