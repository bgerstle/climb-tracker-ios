//
//  Climb.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

typealias ProjectID = UUID
typealias AttemptID = UUID

// Cannot conform to Identifiable since that introduces "Self" requirements that prevent specifying
// mixed collections of projects (e.g. [Boulder, Rope...])
protocol AnyProject {
    var id: ProjectID { get }
    var createdAt: Date { get }
    var rawGrade: String { get }
    var attempts: [AnyAttempt] { get }

    // convert from Any to specific Project type
    var match: Project { get }
}

protocol AnyAttempt {
    var didSend: Bool { get }
}

enum Project {
    case boulder(BoulderProject)
    case rope(RopeProject)

    var eraseToAny: AnyProject {
        switch self {
        case .boulder(let project):
            return project
        case .rope(let project):
            return project
        }
    }
}

protocol ProjectType: Identifiable, AnyProject, Hashable
where ID == ProjectID {}

protocol AttemptType: Identifiable, AnyAttempt, Hashable
where ID == AttemptID {}

struct BoulderProject : ProjectType {
    typealias ID = ProjectID

    let id: ProjectID
    let createdAt: Date
    let grade: AnyBoulderGrade

    struct Attempt: AttemptType {
        let id: AttemptID
        let didSend: Bool
    }
    let boulderAttempts: [Attempt]

    var rawGrade: String { grade.rawValue }
    var attempts: [AnyAttempt] { boulderAttempts }
    var match: Project { .boulder(self) }

    struct Created {
        let projectId: ProjectID
        let createdAt: Date
        let grade: AnyBoulderGrade
    }

    struct Attempted {
        let projectId: ProjectID
        let attemptId: UUID
        let didSend: Bool
        let attemptedAt: Date
    }

    enum Event : TopicEvent {
        static var namespace: String { "boulder-projects" }

        case created(Created)
        case attempted(Attempted)
    }

    init(_ event: Created) {
        self.id = event.projectId
        self.createdAt = event.createdAt
        self.grade = event.grade
        self.boulderAttempts = []
    }
}

struct RopeProject : Identifiable, AnyProject, Hashable {
    typealias ID = ProjectID

    let id: ProjectID
    let createdAt: Date
    let grade: AnyRopeGrade

    enum Subcategory {
        case topRope, sport
    }

    struct Attempt: AttemptType {
        let id: AttemptID
        let didSend: Bool
        let subcategory: Subcategory
    }

    let ropeAttempts: [Attempt]

    var rawGrade: String { grade.rawValue }
    var attempts: [AnyAttempt] { ropeAttempts }
    var match: Project { .rope(self) }

    struct Created {
        let projectId: UUID
        let createdAt: Date
        let grade: AnyRopeGrade
    }

    struct Attempted {
        let projectId: UUID
        let attemptId: UUID
        let didSend: Bool
        let attemptedAt: Date
        let subcategory: Subcategory
    }

    enum Event : TopicEvent {
        static var namespace: String { "rope-projects" }
        
        case created(Created)
        case attempted(Attempted)
    }

    init(_ event: Created) {
        self.id = event.projectId
        self.createdAt = event.createdAt
        self.grade = event.grade
        self.ropeAttempts = []
    }
}
