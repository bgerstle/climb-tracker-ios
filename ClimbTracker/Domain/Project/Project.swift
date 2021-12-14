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
    }
    var boulderAttempts: [Attempt]

    var rawGrade: String { grade.rawValue }
    var attempts: [AnyAttempt] { boulderAttempts }

    var match: Project { .boulder(self) }

    struct Created : Equatable, Hashable, Codable {
        let projectId: ProjectID
        let createdAt: Date
        let grade: AnyBoulderGrade
    }

    struct Attempted : Equatable, Hashable, Codable {
        let projectId: ProjectID
        let attemptId: AttemptID
        let didSend: Bool
        let attemptedAt: Date
    }

    enum Event : PersistableTopicEvent, Equatable {
        static var namespace: String { "boulder-projects" }

        case created(Created)
        case attempted(Attempted)

        enum PayloadType : String, CaseIterable, StringRawRepresentable {
            case created = "created"
            case attempted = "attempted"
        }

        var payloadType: PayloadType {
            switch self {
            case .created(_):
                return .created
            case .attempted(_):
                return .attempted
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
            case .created(let createdPayload):
                return try Self.encoder.encode(createdPayload)
            case .attempted(let attemptedPayload):
                return try Self.encoder.encode(attemptedPayload)
            }
        }

        init(payloadType: PayloadType, payload: Data) throws {
            switch payloadType {
            case .created:
                self = .created(try Self.decoder.decode(Created.self, from: payload))
            case .attempted:
                self = .attempted(try Self.decoder.decode(Attempted.self, from: payload))
            }
        }
    }
}

struct RopeProject : ProjectType {
    typealias ID = ProjectID

    let id: ProjectID
    let createdAt: Date
    let grade: AnyRopeGrade

    enum Subcategory : String, Hashable, Codable {
        case topRope = "topRope"
        case sport = "sport"
    }

    struct Attempt: AttemptType {
        let id: AttemptID
        let didSend: Bool
        let subcategory: Subcategory
        let attemptedAt: Date
    }

    var ropeAttempts: [Attempt]

    var rawGrade: String { grade.rawValue }
    var attempts: [AnyAttempt] { ropeAttempts }
    var match: Project { .rope(self) }

    struct Created : Hashable, Codable {
        let projectId: UUID
        let createdAt: Date
        let grade: AnyRopeGrade
    }

    struct Attempted : Hashable, Codable {
        let projectId: ProjectID
        let attemptId: AttemptID
        let didSend: Bool
        let attemptedAt: Date
        let subcategory: Subcategory
    }

    enum Event : PersistableTopicEvent {
        static var namespace: String { "rope-projects" }
        
        case created(Created)
        case attempted(Attempted)

        enum PayloadType : String, CaseIterable, StringRawRepresentable {
            case created = "created"
            case attempted = "attempted"
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
            }
        }

        var payloadType: PayloadType {
            switch self {
            case .created(_):
                return .created
            case .attempted(_):
                return .attempted
            }
        }

        init(payloadType: PayloadType, payload: Data) throws {
            switch payloadType {
            case .created:
                self = .created(try Self.decoder.decode(Created.self, from: payload))
            case .attempted:
                self = .attempted(try Self.decoder.decode(Attempted.self, from: payload))
            }
        }
    }
}
