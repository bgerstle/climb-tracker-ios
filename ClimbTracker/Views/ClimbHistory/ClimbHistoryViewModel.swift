//
//  ClimbHistoryViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine
import SwiftUI

class ClimbHistoryViewModel: ObservableObject {
    @Published var createdClimbs: [AnyClimb] = []
    var cancellable: AnyCancellable?

    func handleClimbEvents<P: Publisher>(_ publisher: P)
        -> AnyCancellable
        where P.Output == EventEnvelope<ClimbEvent>, P.Failure == Never
    {
        return publisher.sink { climbEvent in
            switch climbEvent.event {
            case .created(let climb):
                self.createdClimbs.insert(climb, at: 0)
            }
        }
    }
}
