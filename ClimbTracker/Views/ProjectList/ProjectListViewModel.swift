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

    enum Event {
        case created(ProjectSummary)
    }
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

    func summarizeProjectEvents<PB: Publisher, PR: Publisher>(boulder: PB, rope: PR) -> AnyPublisher<EventEnvelope<ProjectSummary.Event>, Never>
    where PB.Output == EventEnvelope<BoulderProject.Event>,
          PB.Failure == Never,
          PR.Output == EventEnvelope<RopeProject.Event>,
          PR.Failure == Never
    {
        let boulderSummaries = boulder.map(summarize),
            ropeSummaries = rope.map(summarize),
            allSummaries = boulderSummaries.merge(with: ropeSummaries)
        return allSummaries.eraseToAnyPublisher()
    }

    private func summarize(_ envelope: EventEnvelope<BoulderProject.Event>) -> EventEnvelope<ProjectSummary.Event> {
        switch envelope.event {
        case .created(let event):
            let summary = ProjectSummary(id: event.id,
                                         didSend: false,
                                         attemptCount: 0,
                                         title: formattedTitle(.boulder, createdAt: event.createdAt),
                                         grade: event.grade.rawValue)
            return EventEnvelope(event: .created(summary), timestamp: Date())
        }
    }

    private func summarize(_ envelope: EventEnvelope<RopeProject.Event>) -> EventEnvelope<ProjectSummary.Event> {
        switch envelope.event {
        case .created(let event):
            let summary = ProjectSummary(id: event.id,
                                         didSend: false,
                                         attemptCount: 0,
                                         title: formattedTitle(.boulder, createdAt: event.createdAt),
                                         grade: event.grade.rawValue)
            return EventEnvelope(event: .created(summary), timestamp: Date())
        }
    }

    private func formattedTitle(_ category: ProjectCategory, createdAt: Date) -> String {
        return "\(category.displayTitle) \(dateFormatter.string(from: createdAt))"
    }
}

class ProjectListViewModel: ObservableObject {
    // TODO: replace w/ project repository
    @Published var projects: [ProjectSummary] = []
    var cancellable: AnyCancellable?

    func logAttempt(didSend: Bool, project: UUID) {
        
    }

    func handleSummaryEvents<P: Publisher>(_ publisher: P) -> AnyCancellable
    where P.Output == EventEnvelope<ProjectSummary.Event>, P.Failure == Never
    {
        return publisher.sink { summaryEventEnvelope in
            switch summaryEventEnvelope.event {
            case .created(let summary):
                self.projects.insert(summary, at: 0)
            }
        }
    }
}
