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
        let tuple: (PassthroughSubject<EventEnvelope<Climb.Event>, Never>, AnyCancellable)
            = NotificationCenter.default.subject(topic: Climb.Event.self)
        cancelContainer.cancellables.append(tuple.1)
        // let climbEventPublisher = NotificationCenter.default.publisher(topic: Climb.Event.self)
        let historyViewModel = ClimbHistoryViewModel()

        // FIXME: put these cancellables somewhere, or defer their creation?
        let viewModelCancellable = historyViewModel.handleClimbEvents(tuple.0)
        cancelContainer.cancellables.append(viewModelCancellable)

        let climbService = ClimbEventService<PassthroughSubject<EventEnvelope<Climb.Event>, Never>>(subject: tuple.0)

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
