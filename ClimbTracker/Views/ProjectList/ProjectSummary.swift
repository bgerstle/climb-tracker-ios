//
//  ProjectSummary.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/10/21.
//

import Foundation
import Combine
import os

struct ProjectSummary : Identifiable, Hashable, Equatable {
    let id: ProjectID
    let category: ProjectCategory
    let createdAt: Date

    var name: String?
    var grade: String
    var sendCount: Int
    var sessionDates: Set<Date>
    var attemptCount: UInt
    var lastAttempt: Date?
}

actor ProjectSummarizer {
    let logger: Logger = Logger.app(category: "projectSummarizer")

    @Published
    private var projectSummaries = [ProjectSummary]()

    private var currentNames = [ProjectID: String]()

    private var cancellables = Set<AnyCancellable>()

    private func update(_ cancellables: Set<AnyCancellable>) {
        self.cancellables = cancellables
    }

    private func updateSummary(_ summary: ProjectSummary) {
        logger.info("Updating summary \(summary.id)")
        var newSummary = summary
        newSummary.name = self.currentNames[summary.id]
        if let summaryIndex = self.projectSummaries.firstIndex(where: { $0.id == newSummary.id }) {
            self.projectSummaries[summaryIndex] = newSummary
        } else {
            self.projectSummaries.append(newSummary)
        }
        self.projectSummaries.sort(using: ProjectSummary.lastAttemptSortComparator())
    }

    private func updateSummary(_ nameEvent: ProjectNameEvent) {
        switch nameEvent {
        case .named(let payload):
            logger.info("Updating summary name \(payload.projectId)")
            // TODO: support renaming
            currentNames[payload.projectId] = payload.name
            if let summaryIndex = self.projectSummaries.firstIndex(where: { $0.id == payload.projectId }) {
                let existingSummary = projectSummaries[summaryIndex]
                var newSummary = existingSummary
                newSummary.name = payload.name
                projectSummaries[summaryIndex] = newSummary
            }
        }
    }

    nonisolated func summarizeProjectEvents<PB: Publisher, PR: Publisher, PN: Publisher>(
            boulder: PB,
            rope: PR,
            name: PN
    ) -> AnyPublisher<[ProjectSummary], Never>
    where PB.Output == EventEnvelope<BoulderProject.Event>,
          PB.Failure == Never,
          PR.Output == EventEnvelope<RopeProject.Event>,
          PR.Failure == Never,
          PN.Output == EventEnvelope<ProjectNameEvent>,
          PN.Failure == Never
    {
        // TODO: extract into project service
        let boulderProjects = boulder.materializedEntities(BoulderProject.self),
            bouldersAsAny = boulderProjects.map { $0 as AnyProject },
            ropeProjects = rope.materializedEntities(RopeProject.self),
            ropesAsAny = ropeProjects.map { $0 as AnyProject },
            allProjects = bouldersAsAny.merge(with: ropesAsAny),
            namelessSummaries = allProjects.map { proj in
                ProjectSummary(
                    id: proj.id,
                    category: proj.category,
                    createdAt: proj.createdAt,
                    name: nil,
                    grade: proj.rawGrade,
                    sendCount: proj.attempts.filter(\.didSend).count,
                    sessionDates: Set(proj.attempts.map(\.attemptedAt).map(Calendar.defaultClimbCalendar.startOfDay)),
                    attemptCount: UInt(proj.attempts.count),
                    lastAttempt: proj.attempts.map(\.attemptedAt).max()
                )
            }

        let c1 = namelessSummaries.sink { summary in
                Task {
                    await self.updateSummary(summary)
                }
            }

        let c2 = name.sink { nameEventEnvelope in
                Task {
                    await self.updateSummary(nameEventEnvelope.event)
                }
            }

        Task {
            await self.update(Set([c1, c2]))
        }

        return Future { promise in
            Task {
                promise(.success(await self.$projectSummaries))
            }
        }.flatMap { $0 }.eraseToAnyPublisher()
    }
}
