//
//  ProjectDetailsViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/10/21.
//

import Foundation
import Combine
import os

@MainActor
class ProjectDetailsViewModel : ObservableObject {
    private static let logger = Logger.app(category: "projectDetailsViewModel")

    @Published
    private(set) var project: AnyProject? = nil

    func subscribe(projectId: ProjectID, category: ProjectCategory) {
        project = nil
        cancellable = createSubscription(projectId: projectId, category: category)
    }

    private let projectService: ProjectService
    private var cancellable: AnyCancellable? = nil

    init(projectService: ProjectService) {
        self.projectService = projectService
    }

    private func createSubscription(projectId: ProjectID, category: ProjectCategory) -> AnyCancellable {
        switch category {
        case .boulder:
            return projectService.subscribeToProject(withType: BoulderProject.self, id: projectId)
                .receive(on: DispatchQueue.main)
                .sink { self.update(projectType: BoulderProject.self, envelope: $0) }

        case .rope:
            return projectService.subscribeToProject(withType: RopeProject.self, id: projectId)
                .receive(on: DispatchQueue.main)
                .sink { self.update(projectType: RopeProject.self, envelope: $0) }
        }
    }

    func update<T: EventSourcedProject>(projectType: T.Type, envelope: EventEnvelope<T.Event>) {
        // use `map` since (unlike guard let) it allows project to be nil
        let projectAsExpectedType = project.map { $0 as! T }
        project = T.apply(event: envelope.event, to: projectAsExpectedType)
    }
}
