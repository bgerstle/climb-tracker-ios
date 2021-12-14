//
//  DummyServices.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/11/21.
//

import Foundation
import SwiftUI

// Dummy services that can only be used in previews
class PreviewProjectService : ProjectService {
    func subscribeToProject<T>(withType projectType: T.Type, id projectId: ProjectID) -> TopicEventPublisher<T.Event> where T : EventSourcedProject {
        return [EventEnvelope<T.Event>]().publisher.eraseToAnyPublisher()
    }

    func create<G: BoulderGrade>(grade: G) async throws -> ProjectID {
        UUID()
    }

    func create<G: RopeGrade>(grade: G) async throws -> ProjectID {
        UUID()
    }

    func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory) async throws -> AttemptID {
        UUID()
    }

    func attempt(projectId: UUID, at: Date, didSend: Bool) async throws -> AttemptID {
        UUID()
    }

    init<P: PreviewProvider>(_ _: P.Type) { }
}

class PreviewProjectNameService : ProjectNameService {
    func name(projectId: ProjectID, _ name: String) async throws {

    }

    func getProject(forName: String) async throws -> ProjectID? {
        nil
    }

    func getName(forProject: ProjectID) async throws -> String? {
        nil
    }

    init<P: PreviewProvider>(_ _: P.Type) { }
}

extension PreviewProvider {
    static var previewProjectService: PreviewProjectService { PreviewProjectService(Self.self) }

    static var previewProjectNameService: PreviewProjectNameService { PreviewProjectNameService(Self.self) }
}
