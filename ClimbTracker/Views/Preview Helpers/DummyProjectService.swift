//
//  DummyProjectService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/11/21.
//

import Foundation
import SwiftUI

// Dummy services that can only be used in previews
class DummyProjectService : ProjectService {
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

extension PreviewProvider {
    static var dummyProjectService: DummyProjectService { DummyProjectService(Self.self) }
}
