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
        let boulderSubject = PassthroughSubject<EventEnvelope<BoulderProject.Event>, Never>()
        let ropeSubject = PassthroughSubject<EventEnvelope<RopeProject.Event>, Never>()

        let summarizer: ProjectSummarizer = ProjectSummarizer(),
            summaryEventPublisher = summarizer.summarizeProjectEvents(boulder: boulderSubject, rope: ropeSubject)
        
        let historyViewModel = ProjectListViewModel()

        // FIXME: put these cancellables somewhere, or defer their creation?
        let viewModelCancellable = historyViewModel.handleClimbEvents(summaryEventPublisher)
        cancelContainer.cancellables.append(viewModelCancellable)

        let ropeProjectService = RopeProjectEventService(subject: ropeSubject),
            boulderProjectService = BoulderProjectEventService(subject: boulderSubject)

        let addClimbViewModel = AddProjectViewModel(
            boulderProjectService: boulderProjectService,
            ropeProjectService: ropeProjectService
        )

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
