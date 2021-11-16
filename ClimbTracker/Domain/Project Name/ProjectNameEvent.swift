//
//  ProjectNameEvent.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/15/21.
//

import Foundation

enum ProjectNameEvent : TopicEvent {
    static var namespace: String { "project-names" }

    struct Named : Hashable {
        let projectId: ProjectID
        let name: String
    }

    case named(Named)
}
