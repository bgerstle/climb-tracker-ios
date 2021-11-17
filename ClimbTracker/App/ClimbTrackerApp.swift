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
        let eventStore = EphemeralEventStore(),
            projectService = ProjectEventService(eventStore: eventStore),
            summarizer: ProjectSummarizer = ProjectSummarizer(),
            summaryEventPublisher = summarizer.summarizeProjectEvents(
                boulder: projectService.boulderProjectEventPublisher,
                rope: projectService.ropeProjectEventPublisher
            ),
            historyViewModel = ProjectListViewModel(projectService: projectService),
            addProjectViewModel = AddProjectViewModel(projectService: projectService)

        historyViewModel.handleSummaryEvents(summaryEventPublisher)

        return WindowGroup {
            ProjectListView(
                addProjectViewFactory: {
                    AddProjectView(viewModel: addProjectViewModel)
                },
                viewModel: historyViewModel
            )
        }
    }
}
