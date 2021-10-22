//
//  Climb.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

// Type-erased Climb.
// Cannot conform to Identifiable since that introduces "Self" requirements that prevent specifying
// mixed collections of climbs (e.g. [BoulderClimb, RopeClimb...])
protocol AnyProject {
    var createdAt: Date { get }
    var category: Category { get }
    var grade: String { get }
    var id: UUID { get }
}

enum ProjectEvent {
    case created(AnyProject)
}

struct Project<CT: CategoryType>: AnyProject, Hashable {
    let id: UUID

    let createdAt: Date
    var category: Category { CT.id }

    // TODO: rename rawGrade or something
    let grade: String

    var systemicGrade: CT.GradeType { CT.GradeType(rawValue: grade)! }

    init(id: UUID, climbedAt: Date, grade: CT.GradeType) {
        self.id = id
        self.createdAt = climbedAt
        self.grade = grade.rawValue
    }
}
