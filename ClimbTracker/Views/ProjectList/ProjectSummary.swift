//
//  ProjectSummary.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/10/21.
//

import Foundation
import Combine

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

class ProjectSummarizer {
    func summarizeProjectEvents<PB: Publisher, PR: Publisher, PN: Publisher>(
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
            bouldersAsAny = boulderProjects.map { bps in bps.mapValues { $0 as AnyProject }  },
            ropeProjects = rope.materializedEntities(RopeProject.self),
            ropesAsAny = ropeProjects.map { rps in rps.mapValues { $0 as AnyProject }  },
            allProjects = bouldersAsAny.combineLatest(ropesAsAny).map { bps, rps in
                bps.merging(rps, uniquingKeysWith: { bp, rp in
                    fatalError("Expected materialized boulder & rope projects to always be unique, but found duplicates \(bp) and \(rp)")
                })
            },
            // TODO: use projectNamesPublisher
            allNames = name.scan([EventEnvelope<ProjectNameEvent>]()) { names, eventEnvelope in
                names + [eventEnvelope]
            }
            .map { $0.currentNamedProjects() },
        projectSummaries = allProjects.combineLatest(allNames).map { projs, names in
            projs.values.map { proj in
                ProjectSummary(
                    id: proj.id,
                    category: proj.category,
                    createdAt: proj.createdAt,
                    name: names[proj.id],
                    grade: proj.rawGrade,
                    sendCount: proj.attempts.filter(\.didSend).count,
                    sessionDates: Set(proj.attempts.map(\.attemptedAt).map(Calendar.defaultClimbCalendar.startOfDay)),
                    attemptCount: UInt(proj.attempts.count),
                    lastAttempt: proj.attempts.map(\.attemptedAt).max()
                )
            }
        }

        return projectSummaries.assertNoFailure().eraseToAnyPublisher()
    }
}
