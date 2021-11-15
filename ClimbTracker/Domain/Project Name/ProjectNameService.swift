//
//  ProjectNameService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/15/21.
//

import Foundation

protocol ProjectNameService {
    func name(projectId: ProjectID, _ name: String) async throws

    func find(name: String) async throws -> ProjectID?
}

actor ProjectNameEventService : ProjectNameService {
    private let eventStore: EventStore

    init(eventStore: EventStore) {
        self.eventStore = eventStore
    }

    private func allNamesTopic() async throws -> AnyTopic<ProjectNameEvent> {
        try await eventStore.findOrCreateTopic(id: "all", eventType: ProjectNameEvent.self)
    }

    func find(name: String) async throws -> ProjectID? {
        (try await currentProjectNames())[name]
    }

    private func currentProjectNames() async throws -> [String:ProjectID] {
        let events = try await allNamesTopic().events()
        return events.reduce(into: [String:ProjectID]()) { (names, eventEnvelope) in
            switch eventEnvelope.event {
            case .named(let event):
                names[event.name] = event.projectId
            }
        }
    }

    func name(projectId: ProjectID, _ name: String) async throws {
        if let alreadyNamedProjectId = try await find(name: name), alreadyNamedProjectId != projectId {
            throw NameAlreadyTaken(name: name, unnamedProjectId: projectId, namedProjectId: alreadyNamedProjectId)
        }
        try await allNamesTopic().write(
            EventEnvelope(
                event: ProjectNameEvent.named(ProjectNameEvent.Named(projectId: projectId, name: name)),
                timestamp: Date()
            )
        )
    }
}

struct NameAlreadyTaken : Error {
    let name: String
    let unnamedProjectId: ProjectID
    let namedProjectId: ProjectID
}
