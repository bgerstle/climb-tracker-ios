//
//  ClimbHistoryViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine
import SwiftUI

class ProjectListViewModel: ObservableObject {
    let dateFormatter: DateFormatter
    let ropeProjectService: RopeProjectService
    let boulderProjectService: BoulderProjectService

    var summaryEventSubscription: AnyCancellable?

    static var defaultFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    init(dateFormatter: DateFormatter = defaultFormatter,
         ropeProjectService: RopeProjectService,
         boulderProjectService: BoulderProjectService) {
        self.dateFormatter = dateFormatter
        self.ropeProjectService = ropeProjectService
        self.boulderProjectService = boulderProjectService
    }

    // TODO: replace w/ project repository
    @Published var projects: [ProjectSummary] = []
    var cancellable: AnyCancellable?

    func logAttempt(project: ProjectSummary, didSend: Bool) async throws {
        switch project.category {
        case .boulder:
            try await boulderProjectService.attempt(projectId: project.id,
                                                    at: Date(),
                                                    didSend: didSend)
        case .rope:
            ropeProjectService.attempt(projectId: project.id,
                                       at: Date(),
                                       didSend: didSend,
                                       // TODO: pick a default and eventually use a custom form
                                       subcategory: .sport)
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
            guard let summaryIndex = projects.firstIndex(where: { $0.id == event.id }) else {
                fatalError("Expected summary \(event.id) to have been created, but was not found.")
            }
            var summary = projects[summaryIndex]
            summary.didSend = summary.didSend || event.didSend
            summary.attemptCount += 1
            projects[summaryIndex] = summary
        }
    }

    func handleSummaryEvents<P: Publisher>(_ publisher: P)
    where P.Output == EventEnvelope<ProjectSummary.Event>, P.Failure == Never {
        summaryEventSubscription = publisher.sink { [weak self] (summaryEventEnvelope) in
            self?.handle(summaryEventEnvelope)
        }
    }

    private func formattedTitle(_ category: ProjectCategory, createdAt: Date) -> String {
        return "\(category.displayTitle) \(dateFormatter.string(from: createdAt))"
    }
}
