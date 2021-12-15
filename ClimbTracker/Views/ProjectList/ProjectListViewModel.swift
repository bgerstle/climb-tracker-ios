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
    struct ProjectSortComparator : SortComparator {
        func compare(_ lhs: ProjectSummary, _ rhs: ProjectSummary) -> ComparisonResult {
            let comparison = lhs.lastAttemptOrCreatedAt.compare(rhs.lastAttemptOrCreatedAt)
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
    var lastAttemptOrCreatedAt: Date {
        lastAttempt ?? createdAt
    }

    static func lastAttemptSortComparator(order: SortOrder = .reverse) -> ProjectSortComparator {
        ProjectSortComparator(order: order)
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

    func handleSummaryEvents<P: Publisher>(_ publisher: P)
    where P.Output == [ProjectSummary], P.Failure == Never {
        summaryEventSubscription = publisher
            .receive(on: DispatchQueue.main)
            .sink() { [weak self] summaries in
                self?.projects = summaries.sorted(using: ProjectSummary.lastAttemptSortComparator())
            }
    }
}
