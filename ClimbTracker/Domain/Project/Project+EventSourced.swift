//
//  Project+EventSourced.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/14/21.
//

import Foundation

typealias EventSourcedProject = ProjectType & EventSourced

extension BoulderProject : EventSourced {
    typealias CreateEventPayload = Created

    static func apply(event: Event, to project: Self?) -> Self {
        switch event {
        case .created(let created):
            guard project == nil else {
                fatalError("Can't apply created event \(event) to existing project \(String(describing: project))")
            }
            return BoulderProject(createdEvent: created)
        case .attempted(let attempted):
            guard var project = project else {
                fatalError("Invalid attempt to apply \(attempted) to nil project, make sure created event is ordered before others.")
            }
            project.apply(attempted)
            return project
        }
    }

    init(createdEvent: Created) {
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
}

extension RopeProject : EventSourced {
    typealias CreateEventPayload = Created

    static func apply(event: Event, to project: Self?) -> Self {
        switch event {
        case .created(let created):
            // TODO: DRY up the "created vs. updated event" validations
            guard project == nil else {
                fatalError("Can't apply created event \(event) to existing project \(String(describing: project))")
            }
            return RopeProject(createdEvent: created)
        case .attempted(let attempted):
            guard var project = project else {
                fatalError("Invalid attempt to apply \(attempted) to nil project, make sure created event is ordered before others.")
            }
            project.apply(attempted)
            return project
        }
    }

    init(createdEvent: Created) {
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
}
