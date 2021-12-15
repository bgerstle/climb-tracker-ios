//
//  Project+EventSourced.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/14/21.
//

import Foundation

typealias EventSourcedProject = ProjectType & EventSourced

fileprivate extension ProjectType {
    func indexOfAttempt(withId attemptId: AttemptID) -> Int {
        guard let existingAttemptIndex = attempts.firstIndex(where: { $0.id == attemptId }) else {
            fatalError("Could not find attempt \(attemptId) to update in project \(id)")
        }
        return existingAttemptIndex
    }
}

extension BoulderProject : EventSourced {
    static func apply(event: Event, to project: Self?) -> Self {
        switch event {
        case .created(let created):
            guard project == nil else {
                fatalError("Can't apply created event \(event) to existing project \(String(describing: project))")
            }
            return BoulderProject(created)
        case .attempted(let attempted):
            guard var project = project else {
                fatalError("Invalid attempt to apply \(attempted) to nil project, make sure created event is ordered before others.")
            }
            project.apply(attempted)
            return project
        case .attemptUpdated(let attemptUpdated):
            guard var project = project else {
                fatalError("Invalid attempt to apply \(attemptUpdated) to nil project, make sure created event is ordered before others.")
            }
            project.apply(attemptUpdated)
            return project
        }
    }

    init(_ createdEvent: Created) {
        self.id = createdEvent.projectId
        self.createdAt = createdEvent.createdAt
        self.grade = createdEvent.grade
        self.boulderAttempts = []
    }

    private mutating func apply(_ event: Attempted) {
        boulderAttempts.append(Attempt(
            id: event.attemptId,
            didSend: event.didSend,
            attemptedAt: event.attemptedAt
        ))
    }

    private mutating func apply(_ event: AttemptUpdated) {
        boulderAttempts[indexOfAttempt(withId: event.attemptId)] = Attempt(
            id: event.attemptId,
            didSend: event.didSend,
            attemptedAt: event.attemptedAt
        )
    }
}

extension RopeProject : EventSourced {
    static func apply(event: Event, to project: Self?) -> Self {
        switch event {
        case .created(let created):
            // TODO: DRY up the "created vs. updated event" validations
            guard project == nil else {
                fatalError("Can't apply created event \(event) to existing project \(String(describing: project))")
            }
            return RopeProject(created)
        case .attempted(let attempted):
            guard var project = project else {
                fatalError("Invalid attempt to apply \(attempted) to nil project, make sure created event is ordered before others.")
            }
            project.apply(attempted)
            return project
        case .attemptUpdated(let attemptUpdated):
            guard var project = project else {
                fatalError("Invalid attempt to apply \(attemptUpdated) to nil project, make sure created event is ordered before others.")
            }
            project.apply(attemptUpdated)
            return project
        }
    }

    init(_ createdEvent: Created) {
        self.id = createdEvent.projectId
        self.createdAt = createdEvent.createdAt
        self.grade = createdEvent.grade
        self.ropeAttempts = []
    }

    mutating func apply(_ event: Attempted) {
        ropeAttempts.append(Attempt(
            id: event.attemptId,
            didSend: event.didSend,
            subcategory: event.subcategory,
            attemptedAt: event.attemptedAt
        ))
    }

    private mutating func apply(_ event: AttemptUpdated) {
        ropeAttempts[indexOfAttempt(withId: event.attemptId)] = Attempt(
            id: event.attemptId,
            didSend: event.didSend,
            subcategory: event.subcategory,
            attemptedAt: event.attemptedAt
        )
    }
}
