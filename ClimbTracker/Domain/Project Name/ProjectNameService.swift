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
}
