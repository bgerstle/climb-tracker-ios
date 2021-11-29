//
//  NamedProjectCreationWorkflow.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/17/21.
//

import Foundation

extension ProjectNameService {
    typealias AsyncThrowingProjectFactory<G: Grade> = (G) async throws -> ProjectID

    // Orchestrate project creation & naming.
    @discardableResult
    func createProject<G: Grade>(grade: G,
                                 name: String?,
                                 withFactory factory: AsyncThrowingProjectFactory<G>) async throws -> ProjectID {
        let projectId = try await factory(grade)
        if let name = name {
            try await self.name(projectId: projectId, name)
        }
        return projectId
    }
}
