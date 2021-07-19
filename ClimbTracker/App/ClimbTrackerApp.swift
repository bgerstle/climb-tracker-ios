//
//  ClimbTrackerApp.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/2/21.
//

import SwiftUI
import Combine

@main
struct ClimbTrackerApp: App {
    class CancelContainer {
        var cancellables: [AnyCancellable] = []
    }
    let cancelContainer = CancelContainer()

    var body: some Scene {
        // do I even need NotificationCenter?....
        let subject = PassthroughSubject<EventEnvelope<Climb.Event>, Never>()

        // let climbEventPublisher = NotificationCenter.default.publisher(topic: Climb.Event.self)
        let historyViewModel = ClimbHistoryViewModel()

        // FIXME: put these cancellables somewhere, or defer their creation?
        let viewModelCancellable = historyViewModel.handleClimbEvents(subject)
        cancelContainer.cancellables.append(viewModelCancellable)

        let climbService = ClimbEventService<PassthroughSubject<EventEnvelope<Climb.Event>, Never>>(subject: subject)

        return WindowGroup {
            ClimbHistoryList(
                addClimbViewFactory: {
                    AddClimbView(climbService: climbService)
                },
                viewModel: historyViewModel
            )
        }
    }
}
