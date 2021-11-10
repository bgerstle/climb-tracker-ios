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
