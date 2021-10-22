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
        let subject = PassthroughSubject<EventEnvelope<ProjectEvent>, Never>()

        // let climbEventPublisher = NotificationCenter.default.publisher(topic: ClimbEvent.self)
        let historyViewModel = ProjectListViewModel()

        // FIXME: put these cancellables somewhere, or defer their creation?
        let viewModelCancellable = historyViewModel.handleClimbEvents(subject)
        cancelContainer.cancellables.append(viewModelCancellable)

        let climbService = ProjectEventService<PassthroughSubject<EventEnvelope<ProjectEvent>, Never>>(subject: subject)

        let addClimbViewModel = AddProjectViewModel(climbService: climbService)

        return WindowGroup {
            ProjectListView(
                addProjectViewFactory: {
                    AddProjectView(addClimbViewModel: addClimbViewModel)
                },
                viewModel: historyViewModel
            )
        }
    }
}
