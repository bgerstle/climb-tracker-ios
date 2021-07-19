//
//  Climb.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

class Climb: Identifiable {
    typealias ID = UUID

    init(id: UUID, attributes: ClimbAttributes) {
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

    enum Category: Hashable, Equatable, CustomStringConvertible {
        case boulder(grade: BoulderGrade)

        var description: String {
            switch self {
            case .boulder(let grade):
                return grade.description
            }
        }
    }

    let kind: Category
}
