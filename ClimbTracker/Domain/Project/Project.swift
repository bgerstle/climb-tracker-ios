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

extension AnyProject {
    var category: ProjectCategory {
        switch self.match {
        case .boulder(_):
            return .boulder
        case .rope(_):
            return .rope
        }
    }
}

protocol AnyAttempt {
    var id: AttemptID { get }
    var didSend: Bool { get }
    var attemptedAt: Date { get }

    var match: Project.Attempt { get }
}

class ErasedAttempt : Identifiable {
    var attempt: AnyAttempt
    init(_ attempt: AnyAttempt) {
        self.attempt = attempt
    }

    typealias ID = AttemptID
    var id: AttemptID { attempt.id }
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

    enum Attempt {
        case boulder(BoulderProject.Attempt)
        case rope(RopeProject.Attempt)
    }
}

protocol ProjectType: Identifiable, AnyProject, Hashable
where ID == ProjectID {
}

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
        let attemptedAt: Date

        var match: Project.Attempt {
            return .boulder(self)
        }
    }
    var boulderAttempts: [Attempt]

    var rawGrade: String { grade.rawValue }
    var attempts: [AnyAttempt] { boulderAttempts }

    var match: Project { .boulder(self) }

    enum Event : PersistableTopicEvent, Equatable, Identifiable {
        static var namespace: String { "boulder-projects" }

        struct Created : Equatable, Hashable, Codable {
            let projectId: ProjectID
            let createdAt: Date
            let grade: AnyBoulderGrade
        }
        case created(Created)

        struct Attempted : Equatable, Hashable, Codable {
            let projectId: ProjectID
            let attemptId: AttemptID
            let didSend: Bool
            let attemptedAt: Date
        }
        case attempted(Attempted)

        struct AttemptUpdated : Equatable, Hashable, Codable {
            let projectId: ProjectID
            let attemptId: AttemptID
            let didSend: Bool
            let attemptedAt: Date
        }
        case attemptUpdated(AttemptUpdated)

        enum PayloadType : String, CaseIterable, StringRawRepresentable {
            case created = "created"
            case attempted = "attempted"
            case attemptUpdated = "attemptUpdated"
        }

        var payloadType: PayloadType {
            switch self {
            case .created(_):
                return .created
            case .attempted(_):
                return .attempted
            case .attemptUpdated(_):
                return .attemptUpdated
            }
        }

        // Probably better to use Avro at some point...
        static var decoder: JSONDecoder {
            JSONDecoder()
        }

        static var encoder: JSONEncoder {
            JSONEncoder()
        }

        func payload() throws -> Data {
            switch self {
            case .created(let payload):
                return try Self.encoder.encode(payload)
            case .attempted(let payload):
                return try Self.encoder.encode(payload)
            case .attemptUpdated(let payload):
                return try Self.encoder.encode(payload)
            }
        }

        init(payloadType: PayloadType, payload: Data) throws {
            switch payloadType {
            case .created:
                self = .created(try Self.decoder.decode(Event.Created.self, from: payload))
            case .attempted:
                self = .attempted(try Self.decoder.decode(Event.Attempted.self, from: payload))
            case .attemptUpdated:
                self = .attemptUpdated(try Self.decoder.decode(Event.AttemptUpdated.self, from: payload))
            }
        }

        typealias ID = ProjectID

        var id: ID {
            switch self {
            case .created(let event):
                return event.projectId
            case .attempted(let event):
                return event.projectId
            case .attemptUpdated(let event):
                return event.projectId
            }
        }
    }
}

struct RopeProject : ProjectType {
    typealias ID = ProjectID

    let id: ProjectID
    let createdAt: Date
    let grade: AnyRopeGrade

    enum Subcategory : String, Hashable, Codable, CaseIterable {
        case topRope = "topRope"
        case sport = "sport"
    }

    struct Attempt: AttemptType {
        let id: AttemptID
        let didSend: Bool
        let subcategory: Subcategory
        let attemptedAt: Date

        var match: Project.Attempt {
            return .rope(self)
        }
    }

    var ropeAttempts: [Attempt]

    var rawGrade: String { grade.rawValue }
    var attempts: [AnyAttempt] { ropeAttempts }
    var match: Project { .rope(self) }

    enum Event : PersistableTopicEvent, Identifiable {
        static var namespace: String { "rope-projects" }

        struct Created : Hashable, Codable {
            let projectId: UUID
            let createdAt: Date
            let grade: AnyRopeGrade
        }
        case created(Created)

        struct Attempted : Hashable, Codable {
            let projectId: ProjectID
            let attemptId: AttemptID
            let didSend: Bool
            let attemptedAt: Date
            let subcategory: Subcategory
        }
        case attempted(Attempted)

        struct AttemptUpdated : Equatable, Hashable, Codable {
            let projectId: ProjectID
            let attemptId: AttemptID
            let didSend: Bool
            let attemptedAt: Date
            let subcategory: Subcategory
        }
        case attemptUpdated(AttemptUpdated)

        enum PayloadType : String, CaseIterable, StringRawRepresentable {
            case created = "created"
            case attempted = "attempted"
            case attemptUpdated = "attemptUpdated"
        }

        static var decoder: JSONDecoder {
            JSONDecoder()
        }

        static var encoder: JSONEncoder {
            JSONEncoder()
        }

        func payload() throws -> Data {
            switch self {
            case .created(let payload):
                return try Self.encoder.encode(payload)
            case .attempted(let payload):
                return try Self.encoder.encode(payload)
            case .attemptUpdated(let payload):
                return try Self.encoder.encode(payload)
            }
        }

        var payloadType: PayloadType {
            switch self {
            case .created(_):
                return .created
            case .attempted(_):
                return .attempted
            case .attemptUpdated(_):
                return .attemptUpdated
            }
        }

        init(payloadType: PayloadType, payload: Data) throws {
            switch payloadType {
            case .created:
                self = .created(try Self.decoder.decode(Event.Created.self, from: payload))
            case .attempted:
                self = .attempted(try Self.decoder.decode(Event.Attempted.self, from: payload))
            case .attemptUpdated:
                self = .attemptUpdated(try Self.decoder.decode(Event.AttemptUpdated.self, from: payload))
            }
        }

        typealias ID = ProjectID

        var id: ID {
            switch self {
            case .created(let event):
                return event.projectId
            case .attempted(let event):
                return event.projectId
            case .attemptUpdated(let event):
                return event.projectId
            }
        }
    }
}
