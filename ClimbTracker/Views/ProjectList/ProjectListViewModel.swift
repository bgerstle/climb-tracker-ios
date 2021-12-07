//
//  ProjectListViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine
import SwiftUI

extension Calendar {
    // TODO: properly test support for attempts logged in different timezones
    static var defaultClimbCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }
}

extension ProjectSummary {
    struct LastAttemptSortComparator : SortComparator {
        func compare(_ lhs: ProjectSummary, _ rhs: ProjectSummary) -> ComparisonResult {
            let comparison = lhs.lastAttemptOrDefault.compare(rhs.lastAttemptOrDefault)
            switch order {
            case .forward:
                return comparison
            case .reverse:
                switch comparison {
                case .orderedAscending:
                    return .orderedDescending
                case .orderedDescending:
                    return .orderedAscending
                case .orderedSame:
                    return .orderedSame
                }
            }
        }

        var order: SortOrder

        typealias Compared = ProjectSummary
    }

    // default nil dates to distantFuture, to keep new projects at the top
    var lastAttemptOrDefault: Date {
        lastAttempt ?? Date.distantFuture
    }

    static func lastAttemptSortComparator(order: SortOrder = .reverse) -> LastAttemptSortComparator {
        LastAttemptSortComparator(order: order)
    }
}

@MainActor
class ProjectListViewModel: ObservableObject {
    let projectService: ProjectService

    var summaryEventSubscription: AnyCancellable?

    init(projectService: ProjectService) {
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
                sendCount: 0,
                sessionDates: Set(),
                attemptCount: 0,
                lastAttempt: nil
            )
            // insert new projects to top of the list
            projects.insert(summary, at: 0)
        case .attempted(let event):
            updateSummary(withProjectId: event.projectId) { summary in
                if event.didSend {
                    summary.sendCount += 1
                }
                summary.attemptCount += 1
                summary.lastAttempt = event.attemptedAt

                summary.sessionDates.insert(Calendar.defaultClimbCalendar.startOfDay(for: event.attemptedAt))
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

        var updatedProjects = projects
        updatedProjects[summaryIndex] = summary
        updatedProjects.sort(using: ProjectSummary.lastAttemptSortComparator())

        // setting projects "atomically" prevents emitting set & sort as separate events
        projects = updatedProjects
    }

    func handleSummaryEvents<P: Publisher>(_ publisher: P)
    where P.Output == EventEnvelope<ProjectSummary.Event>, P.Failure == Never {
        summaryEventSubscription = publisher
            .receive(on: DispatchQueue.main)
            .sink() { [weak self] in
                self?.handle($0)
            }
    }
}
