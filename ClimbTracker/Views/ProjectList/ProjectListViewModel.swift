//
//  ClimbHistoryViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine
import SwiftUI

struct ProjectSummary : Identifiable, Hashable {
    let id: UUID
    let didSend: Bool
    let attemptCount: UInt
    let title: String
    let grade: String
}

class ProjectSummarizer {
    let dateFormatter: DateFormatter

    static var defaultFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    init(dateFormatter: DateFormatter = defaultFormatter) {
        self.dateFormatter = dateFormatter
    }

    func summarize(_ project: AnyProject) -> ProjectSummary {
        return ProjectSummary(id: project.id,
                              didSend: false,
                              attemptCount: 0,
                              title: formattedTitle(project),
                              grade: project.rawGrade)
    }

    func formattedTitle(_ project: AnyProject) -> String {
        return "\(project.category.displayTitle) \(dateFormatter.string(from: project.createdAt))"
    }
}

class ProjectListViewModel: ObservableObject {
    // TODO: replace w/ project repository
    @Published var projects: [ProjectSummary] = []
    var cancellable: AnyCancellable?

    let summarizer: ProjectSummarizer = ProjectSummarizer()

    func logAttempt(didSend: Bool, project: UUID) {
        
    }

    func handleClimbEvents<P: Publisher>(_ publisher: P)
        -> AnyCancellable
        where P.Output == EventEnvelope<ProjectEvent>, P.Failure == Never
    {
        return publisher.sink { projectEvent in
            switch projectEvent.event {
            case .created(let project):
                self.projects.insert(self.summarizer.summarize(project), at: 0)
            }
        }
    }
}
