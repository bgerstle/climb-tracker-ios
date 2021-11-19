//
//  ProjectNameEvent.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/15/21.
//

import Foundation

enum ProjectNameEvent : PersistableTopicEvent {
    static var namespace: String { "project-names" }

    struct Named : Hashable, Codable {
        let projectId: ProjectID
        let name: String
    }

    case named(Named)

    enum PayloadType : String, CaseIterable, StringRawRepresentable {
        case named = "named"
    }

    static var encoder: JSONEncoder {
        JSONEncoder()
    }

    static var decoder: JSONDecoder {
        JSONDecoder()
    }

    var payload: Data {
        switch self {
        case .named(let payload):
            return try! Self.encoder.encode(payload)
        }
    }

    var payloadType: PayloadType {
        switch self {
        case .named(_):
            return .named
        }
    }

    init?(payloadType: PayloadType, payload: Data) {
        switch payloadType {
        case .named:
            self = .named(try! Self.decoder.decode(Named.self, from: payload))
        }
    }
}
