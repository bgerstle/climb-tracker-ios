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

struct Project<AttemptT: AttemptType> : Identifiable, AnyProject {
    typealias ID = UUID

    let id: UUID
    let createdAt: Date
    let grade: AttemptT.GradeType
    let climbs: [AttemptT]

    var rawGrade: String { grade.rawValue }
    var category: ProjectCategory { AttemptT.projectCategory }
}

extension Project: Equatable where AttemptT: Equatable {}
extension Project: Hashable where AttemptT: Hashable {}
