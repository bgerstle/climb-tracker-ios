//
//  Climb.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

enum ProjectEvent {
    case created(AnyProject)
}

enum ProjectCategory: String, Hashable, CaseIterable {
    case boulder = "boulder",
         rope = "rope"
}

// Cannot conform to Identifiable since that introduces "Self" requirements that prevent specifying
// mixed collections of climbs (e.g. [Boulder, Rope...])
protocol AnyProject {
    var createdAt: Date { get }
    var category: ProjectCategory { get }
    var rawGrade: String { get }
    var id: UUID { get }
}

struct Project<C: ClimbType> : Identifiable, AnyProject {
    typealias ID = UUID

    let id: UUID
    let createdAt: Date
    let grade: C.GradeType
    let climbs: [C]

    var rawGrade: String { grade.rawValue }
    var category: ProjectCategory { C.projectCategory }
}

extension Project: Equatable where C: Equatable {}
extension Project: Hashable where C: Hashable {}
