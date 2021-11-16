//
//  ProjectNameService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/15/21.
//

import Foundation

protocol ProjectNameService {
    func name(projectId: ProjectID, _ name: String) async throws

    func getProject(forName: String) async throws -> ProjectID?

    func getName(forProject: ProjectID) async throws -> String?
}

class ProjectNameEventService : ProjectNameService {
    private let eventStore: EventStore

    init(eventStore: EventStore) {
        self.eventStore = eventStore
    }

    private func allNamesTopic() async throws -> AnyTopic<ProjectNameEvent> {
        // store all events in the same topic to enforce a "single writer"
        try await eventStore.findOrCreateTopic(id: "all", eventType: ProjectNameEvent.self)
    }

    func getProject(forName name: String) async throws -> ProjectID? {
        (try await allNamesTopic().events().currentProjectNames())[name]
    }

    func getName(forProject projectId: ProjectID) async throws -> String? {
        (try await allNamesTopic().events().currentNamedProjects())[projectId]
    }

    func name(projectId: ProjectID, _ name: String) async throws {
        let currentEvents = try await allNamesTopic().events()

        if let otherProjectWithName = currentEvents.currentProjectNames()[name]{
            throw NameAlreadyTaken(name: name, unnamedProjectId: projectId, namedProjectId: otherProjectWithName)
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

struct ProjectAlreadyNamed : Error {
    let name: String
    let projectId: ProjectID
}

extension Sequence where Element == EventEnvelope<ProjectNameEvent> {
    func currentProjectNames() -> [String: ProjectID] {
        reduce(into: [String:ProjectID]()) { (names, eventEnvelope) in
            switch eventEnvelope.event {
            case .named(let event):
                // probably more efficient to use a bimap but this will likely be a local db eventually
                if let projectBeingRenamed = names.first(where: { $0.value == event.projectId }) {
                    names[projectBeingRenamed.key] = nil
                }
                names[event.name] = event.projectId
            }
        }
    }

    func currentNamedProjects() -> [ProjectID: String] {
        currentProjectNames().reverseLookup()
    }
}

extension Dictionary where Value: Hashable {
    func reverseLookup() -> Dictionary<Value, Key> {
        reduce(into: [Value:Key]()) { (reverseEntries, entry) in
            reverseEntries[entry.value] = entry.key
        }
    }
}
