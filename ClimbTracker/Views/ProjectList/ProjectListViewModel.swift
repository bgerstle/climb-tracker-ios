//
//  ProjectListViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ProjectListViewModel: ObservableObject {
    let dateFormatter: DateFormatter
    let projectService: ProjectService

    var summaryEventSubscription: AnyCancellable?

    private static let defaultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    init(dateFormatter: DateFormatter = defaultFormatter,
         projectService: ProjectService) {
        self.dateFormatter = dateFormatter
        self.projectService = projectService
    }

    // TODO: replace w/ project repository
    @Published var projects: [ProjectSummary] = []
    var cancellable: AnyCancellable?

    func logAttempt(project: ProjectSummary, didSend: Bool) {
        Task {
            do {
                switch project.category {
                case .boulder:
                    try await projectService.attempt(projectId: project.id,
                                                            at: Date(),
                                                            didSend: didSend)
                case .rope:
                    // TODO: pick a default and eventually use a custom form
                    try await projectService.attempt(projectId: project.id,
                                                     at: Date(),
                                                     didSend: didSend,
                                                     subcategory: .sport)
                }
            } catch {
                print("TODO: show this in the UI! \(error)")
            }
        }
    }

    func handle(_ summaryEventEnvelope: EventEnvelope<ProjectSummary.Event>) {
        switch summaryEventEnvelope.event {
        case .created(let event):
            let summary = ProjectSummary(
                id: event.id,
                category: event.category,
                grade: event.grade,
                didSend: false,
                attemptCount: 0,
                title: self.formattedTitle(event.category, createdAt: event.createdAt)
            )
            projects.insert(summary, at: 0)
        case .attempted(let event):
            guard let summaryIndex = projects.firstIndex(where: { $0.id == event.projectId }) else {
                fatalError("Expected summary \(event.projectId) to have been created, but was not found.")
            }
            var summary = projects[summaryIndex]
            summary.didSend = summary.didSend || event.didSend
            summary.attemptCount += 1
            projects[summaryIndex] = summary
        }
    }

    func handleSummaryEvents<P: Publisher>(_ publisher: P)
    where P.Output == EventEnvelope<ProjectSummary.Event>, P.Failure == Never {
        summaryEventSubscription = publisher
            .receive(on: DispatchQueue.main)
            .sink() { [weak self] in
                self?.handle($0)
            }
    }

    private func formattedTitle(_ category: ProjectCategory, createdAt: Date) -> String {
        return "\(category.displayTitle) \(dateFormatter.string(from: createdAt))"
    }
}
