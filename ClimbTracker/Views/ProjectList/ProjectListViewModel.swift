//
//  ClimbHistoryViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine
import SwiftUI

class ProjectListViewModel: ObservableObject {
    // TODO: replace w/ project repository
    @Published var projects: [AnyProject] = []
    var cancellable: AnyCancellable?

    func logAttempt(didSend: Bool, project: UUID) {
        
    }

    func handleClimbEvents<P: Publisher>(_ publisher: P)
        -> AnyCancellable
        where P.Output == EventEnvelope<ProjectEvent>, P.Failure == Never
    {
        return publisher.sink { projectEvent in
            switch projectEvent.event {
            case .created(let climb):
                self.projects.insert(climb, at: 0)
            }
        }
    }
}
