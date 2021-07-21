//
//  Climb.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

enum Category: String, Hashable, Equatable, CaseIterable, Identifiable {
    case boulder = "boulder",
         topRope = "topRope",
         sport = "sport"

    var displayTitle: String {
        switch self {
        case .boulder:
            return "Boulder"
        case .sport:
            return "Sport"
        case .topRope:
            return "Top Rope"
        }
    }

    var id: Category { self }
}

protocol CategoryType {
    associatedtype GradeType: Grade

    static var id: Category { get }
}

protocol GradeType: CustomStringConvertible { }

protocol Grade: GradeType, Hashable, Identifiable, CaseIterable, RawRepresentable
where RawValue == String, AllCases: RandomAccessCollection {
}

final class BoulderCategory: CategoryType {
    typealias GradeType = BoulderGrade

    static let id = Category.boulder
}

final class TopRopeCategory: CategoryType {
    typealias GradeType = RopeGrade

    static let id = Category.topRope
}

final class SportCategory: CategoryType {
    typealias GradeType = RopeGrade

    static let id = Category.sport
}

class Climb: Identifiable {
    typealias ID = UUID

    struct Attributes {
        let climbedAt: Date
        let category: Category
        let grade: GradeType

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
