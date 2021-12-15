//
//  ProjectNameService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/15/21.
//

import Foundation
import Combine

protocol ProjectNameService {
    func name(projectId: ProjectID, _ name: String) async throws

    func getProject(forName: String) async throws -> ProjectID?

    func getName(forProject: ProjectID) async throws -> String?

    var projectNamesPublisher: AnyPublisher<[ProjectID: String], Never> { get }
}

struct NameAlreadyTaken : Error {
    let name: String
    let namedProjectId: ProjectID
}

struct NameEmpty : Error { }

struct ProjectAlreadyNamed : Error {
    let name: String
    let projectId: ProjectID
}

extension ProjectNameService {
    func validate(name: String) async throws {
        // doing separate guards as (arguably premature) optimization, since I can't figure out how to
        // do async boolean expressions
        guard !name.isEmpty else {
            throw NameEmpty()
        }
        if let projectId = try await getProject(forName: name) {
            throw NameAlreadyTaken(name: name, namedProjectId: projectId)
        }
    }
    
    func isValid(name: String) async -> Bool {
        do {
            try await validate(name: name)
        } catch {
            // !!!: will also return false if validation fails
            return false
        }
        return true
    }
}
