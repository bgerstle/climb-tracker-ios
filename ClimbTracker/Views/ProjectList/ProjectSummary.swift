//
//  ProjectSummary.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/10/21.
//

import Foundation
import Combine

struct ProjectSummary : Identifiable, Hashable {
    let id: UUID
    let category: ProjectCategory
    
    var grade: String
    var didSend: Bool
    var attemptCount: UInt
    var title: String

    struct Created {
        let id: UUID
        let createdAt: Date
        let grade: String
        let category: ProjectCategory
    }

    struct Attempted {
        let id: UUID
        let didSend: Bool
    }

    enum Event {
        case created(Created)
        case attempted(Attempted)
    }
}

class ProjectSummarizer {
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
            return EventEnvelope(
                event: .created(ProjectSummary.Created(id: event.projectId,
                                                       createdAt: event.createdAt,
                                                       grade: event.grade.rawValue,
                                                       category: .boulder)),
                timestamp: Date())
        case .attempted(let event):
            return EventEnvelope(
                event: .attempted(ProjectSummary.Attempted(id: event.projectId,
                                                           didSend: event.didSend)),
                timestamp: Date())
        }
    }

    private func summarize(_ envelope: EventEnvelope<RopeProject.Event>) -> EventEnvelope<ProjectSummary.Event> {
        switch envelope.event {
        case .created(let event):
            return EventEnvelope(
                event: .created(ProjectSummary.Created(id: event.projectId,
                                                       createdAt: event.createdAt,
                                                       grade: event.grade.rawValue,
                                                       category: .rope)),
                timestamp: Date())
        case .attempted(let event):
            return EventEnvelope(
                event: .attempted(ProjectSummary.Attempted(id: event.projectId,
                                                           didSend: event.didSend)),
                timestamp: Date())
        }
    }
}
