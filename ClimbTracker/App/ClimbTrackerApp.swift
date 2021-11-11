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
        let boulderSubject = PassthroughSubject<EventEnvelope<BoulderProject.Event>, Never>(),
            ropeSubject = PassthroughSubject<EventEnvelope<RopeProject.Event>, Never>(),
            ropeProjectService = RopeProjectEventService(subject: ropeSubject),
            boulderProjectService = BoulderProjectEventService(subject: boulderSubject),
            summarizer: ProjectSummarizer = ProjectSummarizer(),
            summaryEventPublisher = summarizer.summarizeProjectEvents(boulder: boulderSubject,
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
