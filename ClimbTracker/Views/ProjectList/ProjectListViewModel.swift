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
    var projectNames = [ProjectID: String]()

    func logAttempt(project: ProjectSummary, didSend: Bool) {
        Task {
            do {
                switch project.category {
                case .boulder:
                    let _ = try await projectService.attempt(projectId: project.id,
                                                             at: Date(),
                                                             didSend: didSend)
                case .rope:
                    // TODO: pick a default and eventually use a custom form
                    let _ = try await projectService.attempt(projectId: project.id,
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
                name: projectNames[event.id],
                grade: event.grade,
                didSend: false,
                attemptCount: 0,
                title: self.formattedTitle(event.category, createdAt: event.createdAt)
            )
            projects.insert(summary, at: 0)
        case .attempted(let event):
            updateSummary(withProjectId: event.projectId) { summary in
                summary.didSend = summary.didSend || event.didSend
                summary.attemptCount += 1
            }
        case .named(let event):
            // since named events originate from a separate topic than project events
            // they can arrive out of order (i.e. before created)
            // to accommodate this, names are kept in a separate lookup table and updated
            // both in response to named & created events

            // alternatively, the summary could be created with just the projectId, but I don't
            // want to then handle showing "empty" projects w/ only a name

            projectNames[event.projectId] = event.name

            // only attempt update if summary has been created
            if projects.contains(where: { $0.id == event.projectId}) {
                updateSummary(withProjectId: event.projectId) { summary in
                    summary.name = event.name
                }
            }
        }
    }

    private func updateSummary(withProjectId projectId: ProjectID,
                               _ update: (inout ProjectSummary) -> Void) {
        guard let summaryIndex = projects.firstIndex(where: { $0.id == projectId }) else {
            fatalError("Expected summary \(projectId) to have been created, but was not found.")
        }
        var summary = projects[summaryIndex]
        update(&summary)
        projects[summaryIndex] = summary
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
        return "created at \(dateFormatter.string(from: createdAt))"
    }
}
