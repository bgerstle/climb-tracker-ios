//
//  TestProjectNameService.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/29/21.
//

import Foundation
@testable import ClimbTracker

actor TestProjectNameService : ProjectNameService {
    var names = [String: ProjectID]()

    func name(projectId: ProjectID, _ name: String) async throws {
        names[name] = projectId
    }

    func getProject(forName name: String) async throws -> ProjectID? {
        names[name]
    }

    func getName(forProject projectId: ProjectID) async throws -> String? {
        names.first { (key: String, value: ProjectID) in
            value == projectId
        }?.key
    }
}
