//
//  ProjectSummary.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/10/21.
//

import Foundation
import Combine

struct ProjectSummary : Identifiable, Hashable {
    let id: ProjectID
    let category: ProjectCategory

    var name: String?
    var grade: String
    var didSend: Bool
    var attemptCount: UInt
    var title: String

    enum Event {
        struct Created {
            let id: ProjectID
            let createdAt: Date
            let grade: String
            let category: ProjectCategory
        }

        struct Attempted {
            let projectId: ProjectID
            let didSend: Bool
        }

        struct Named {
            let projectId: ProjectID
            let name: String
        }

        case created(Created)
        case attempted(Attempted)
        case named(Named)
    }
}

class ProjectSummarizer {
    func summarizeProjectEvents<PB: Publisher, PR: Publisher, PN: Publisher>(
            boulder: PB,
            rope: PR,
            name: PN
    ) -> AnyPublisher<EventEnvelope<ProjectSummary.Event>, Never>
    where PB.Output == EventEnvelope<BoulderProject.Event>,
          PB.Failure == Never,
          PR.Output == EventEnvelope<RopeProject.Event>,
          PR.Failure == Never,
          PN.Output == EventEnvelope<ProjectNameEvent>,
          PN.Failure == Never
    {
        let boulderSummaries = boulder.map(summarize),
            ropeSummaries = rope.map(summarize),
            nameSummaries = name.map(summarize),
            allSummaries = boulderSummaries.merge(with: ropeSummaries)
                                           .merge(with: nameSummaries)
        return allSummaries.eraseToAnyPublisher()
    }

    private func summarize(_ envelope: EventEnvelope<ProjectNameEvent>) -> EventEnvelope<ProjectSummary.Event> {
        envelope.map { nameEvent in
            switch nameEvent {
            case .named(let event):
                return ProjectSummary.Event.named(ProjectSummary.Event.Named(
                    projectId: event.projectId, name: event.name
                ))
            }
        }
    }

    private func summarize(_ envelope: EventEnvelope<BoulderProject.Event>) -> EventEnvelope<ProjectSummary.Event> {
        envelope.map { projectEvent in
            switch projectEvent {
            case .created(let event):
                return ProjectSummary.Event.created(ProjectSummary.Event.Created(
                    id: event.projectId,
                    createdAt: event.createdAt,
                    grade: event.grade.rawValue,
                    category: .boulder
                ))
            case .attempted(let event):
                return ProjectSummary.Event.attempted(ProjectSummary.Event.Attempted(
                    projectId: event.projectId,
                    didSend: event.didSend
                ))
            }
        }
    }

    private func summarize(_ envelope: EventEnvelope<RopeProject.Event>) -> EventEnvelope<ProjectSummary.Event> {
        envelope.map { projectEvent in
            switch projectEvent {
            case .created(let event):
                return ProjectSummary.Event.created(ProjectSummary.Event.Created(
                    id: event.projectId,
                    createdAt: event.createdAt,
                    grade: event.grade.rawValue,
                    category: .rope
                ))
            case .attempted(let event):
                return ProjectSummary.Event.attempted(ProjectSummary.Event.Attempted(
                    projectId: event.projectId,
                    didSend: event.didSend
                ))
            }
        }
    }
}
