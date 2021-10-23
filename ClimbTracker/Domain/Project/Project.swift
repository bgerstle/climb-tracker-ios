//
//  Climb.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

// Type-erased Project.
// Cannot conform to Identifiable since that introduces "Self" requirements that prevent specifying
// mixed collections of climbs (e.g. [Boulder, Rope...])
protocol AnyProject {
    var createdAt: Date { get }
    var category: ProjectCategory { get }
    var rawGrade: String { get }
    var id: UUID { get }
}

enum ProjectEvent {
    case created(AnyProject)
}

enum ProjectCategory: String, Hashable, CaseIterable, Identifiable {
    case boulder = "boulder",
         rope = "rope"

    var id: ProjectCategory { self }
}

// Type used to enforce which grades & categories can be used together (see Climb.Attributes)
protocol ProjectCategoryType {
    associatedtype ProjectGradeType: Grade

    static var id: ProjectCategory { get }
}

// ???: Maybe possible to consolidate Boulder/Rope grade into a single generic class w/ conditional conformances based on the grade type used, but in cases where grade system is applicable to both categories it might be ambiguous.

// Boulders can only be assigned a grade applicable to boulders (i.e. not YSD)
final class BoulderCategory<G: Grade> : ProjectCategoryType where G: BoulderGrade {
    typealias ProjectGradeType = G

    static var id: ProjectCategory { ProjectCategory.boulder }
}

// Roped climbs can only be assigned applicable grades (i.e. not Hueco)
final class RopeCategory<G: Grade> : ProjectCategoryType where G: RopeGrade {
    typealias ProjectGradeType = G

    static var id: ProjectCategory { ProjectCategory.rope }
}

struct Project<CT: ProjectCategoryType>: AnyProject, Hashable, Identifiable {
    typealias ID = UUID
    let id: UUID

    let createdAt: Date
    let grade: CT.ProjectGradeType

    var category: ProjectCategory { CT.id }
    var rawGrade: String { grade.rawValue }
    var gradeTypeID: GradeType { CT.ProjectGradeType.typeID }
}
