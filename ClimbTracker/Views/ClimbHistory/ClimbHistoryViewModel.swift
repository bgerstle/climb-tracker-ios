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
    @Published var createdClimbs: [Climb] = []
    var cancellable: AnyCancellable?

    func handleClimbEvents<P: Publisher>(_ publisher: P)
        -> AnyCancellable
        where P.Output == EventEnvelope<Climb.Event>, P.Failure == Never
    {
        return publisher.sink { climbEvent in
            switch climbEvent.event {
            case .created(let climb):
                self.createdClimbs.append(climb)
            }
        }
    }
}
