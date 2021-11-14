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
    var body: some Scene {
        // do I even need NotificationCenter?....
        let eventStore = EphemeralEventStore(),
            ropeSubject = PassthroughSubject<EventEnvelope<RopeProject.Event>, Never>(),
            ropeProjectService = RopeProjectEventService(subject: ropeSubject),
            boulderProjectService = BoulderProjectEventService(eventStore: eventStore),
            summarizer: ProjectSummarizer = ProjectSummarizer(),
            summaryEventPublisher = summarizer.summarizeProjectEvents(boulder: eventStore.namespaceEvents(),
                                                                      rope: ropeSubject),
            historyViewModel = ProjectListViewModel(ropeProjectService: ropeProjectService,
                                                    boulderProjectService: boulderProjectService),
            addClimbViewModel = AddProjectViewModel(
                boulderProjectService: boulderProjectService,
                ropeProjectService: ropeProjectService
            )

        historyViewModel.handleSummaryEvents(summaryEventPublisher)

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
