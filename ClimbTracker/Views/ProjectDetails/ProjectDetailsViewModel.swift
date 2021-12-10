//
//  ProjectDetailsViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/10/21.
//

import Foundation
import Combine

@MainActor
class ProjectDetailsViewModel : ObservableObject {
    @Published
    private(set) var project: AnyProject? = nil

    var projectId: ProjectID? = nil {
        didSet {
            guard let projectId = projectId else {
                project = nil
                return
            }

            print("TODO: find project using \(projectId)")
        }
    }

    private let projectService: ProjectService
    private var cancellable: AnyCancellable? = nil

    init(projectService: ProjectService) {
        self.projectService = projectService
    }
}
