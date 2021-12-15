//
//  EditAttemptViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/15/21.
//

import Foundation

class EditAttemptViewModel : ObservableObject {
    let projectService: ProjectService

    init(projectService: ProjectService) {
        self.projectService = projectService
    }

    func update(boulderAttempt: BoulderProject.Attempt, projectId: ProjectID) async throws {
        try await projectService.updateAttempt(projectId: projectId, attemptId: boulderAttempt.id, didSend: boulderAttempt.didSend, attemptedAt: boulderAttempt.attemptedAt)
    }

    func update(ropeAttempt: RopeProject.Attempt, projectId: ProjectID) async throws {
        try await projectService.updateAttempt(projectId: projectId, attemptId: ropeAttempt.id, didSend: ropeAttempt.didSend, attemptedAt: ropeAttempt.attemptedAt, subcategory: ropeAttempt.subcategory)
    }
}
