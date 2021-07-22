//
//  Climb.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

class Climb: Identifiable {
    typealias ID = UUID

    struct Attributes {
        let climbedAt: Date
        let category: Category
        let grade: AnyGrade

        init<CT: CategoryType>(climbedAt: Date, grade: CT.GradeType, category: CT.Type) {
            self.climbedAt = climbedAt
            self.category = category.id
            self.grade = grade
        }
    }

    init(id: UUID, attributes: Attributes) {
        self.id = id
        self.attributes = attributes
    }

    enum Event {
        case created(climb: Climb)
    }

    let id: UUID

    let attributes: Attributes

    static func create(attributes: Attributes) -> EventEnvelope<Event> {
        return EventEnvelope(
            event: .created(climb: Climb(id: UUID(), attributes: attributes)),
            timestamp: Date()
        )
    }
}
