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
                .sink { self.updateProject($0) }

        case .rope:
            return projectService.subscribeToProject(withType: RopeProject.self, id: projectId)
                .receive(on: DispatchQueue.main)
                .sink { self.updateProject($0) }
        }
    }

    func updateProject(_ envelope: EventEnvelope<BoulderProject.Event>) {
        performUpdate { (boulderProject: BoulderProject?) -> BoulderProject in
            switch envelope.event {
            case .created(let payload):
                precondition(boulderProject == nil)
                return BoulderProject(payload)
            case .attempted(let payload):
                guard var boulderProject = boulderProject else {
                    fatalError("project should have been initialized by created event")
                }
                boulderProject.apply(payload)
                return boulderProject
            }
        }
    }

    func updateProject(_ envelope: EventEnvelope<RopeProject.Event>) {
        performUpdate { (ropeProject: RopeProject?) -> RopeProject in
            switch envelope.event {
            case .created(let payload):
                precondition(ropeProject == nil)
                return RopeProject(payload)
            case .attempted(let payload):
                guard var ropeProject = ropeProject else {
                    fatalError("project should have been initialized by created event")
                }
                ropeProject.apply(payload)
                return ropeProject
            }
        }
    }

    private func performUpdate<T: ProjectType>(_ update: (T?) -> T) {
        guard let project = project else {
            project = update(nil)
            return
        }
        guard let projectAsExpectedType = project as? T else {
            fatalError("expected to update \(T.self) project but got \(project)")
        }
        self.project = update(projectAsExpectedType)
    }
}
