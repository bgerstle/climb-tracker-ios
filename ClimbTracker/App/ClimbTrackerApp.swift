//
//  ClimbTrackerApp.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/2/21.
//

import SwiftUI
import Combine
import GRDB
import os

@main
struct ClimbTrackerApp: App {
    let logger = Logger.app(category: "main")

    let dbManager = DatabaseManager()

    var body: some Scene {
        if CommandLine.arguments.contains("-resetDatabase") {
            try! dbManager.resetDatabase()
        }
        
        // FIXME: remove try!
        let db = try! dbManager.setupDatabase(),
            eventStore = try! PersistentEventStore(db: db),
            projectService = ProjectEventService(eventStore: eventStore),
            projectNameService = ProjectNameEventService(eventStore: eventStore),
            summarizer: ProjectSummarizer = ProjectSummarizer(),
            projectListViewModel = ProjectListViewModel(projectService: projectService)

        if !ProcessInfo.processInfo.isTesting {
            let summaryEventPublisher = summarizer.summarizeProjectEvents(
                boulder: projectService.boulderProjectEventPublisher,
                rope: projectService.ropeProjectEventPublisher,
                name: projectNameService.projectNamedEventPublisher
            )
            projectListViewModel.handleSummaryEvents(summaryEventPublisher)
        }

        let csvImporter = CSVImporter<CSVRow>(projectService: projectService, projectNameService: projectNameService)

        let projectDetailsViewModel = ProjectDetailsViewModel(projectService: projectService,
                                                              projectNameService: projectNameService)

        let edtiAttemptViewModel = EditAttemptViewModel(projectService: projectService)

        return WindowGroup {
            ProjectListView(
                addProjectViewFactory: {
                    AddProjectView(viewModel: AddProjectViewModel(
                        projectService: projectService,
                        projectNameService: projectNameService
                    ))
                },
                viewModel: projectListViewModel
            )
                .onOpenURL { url in
                    // TODO: proper async importing & UI
                    Task {
                        try! await csvImporter.importCSV(url)
                    }
                }
                .environmentObject(projectDetailsViewModel)
                .environmentObject(edtiAttemptViewModel)
        }
    }
}

extension ProcessInfo {
    var isTesting: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}
extension Logger {
    static func app(category: String) -> Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier ?? "unknownBundleID", category: category)
    }
}

// ???: Need to understand why block must be @Sendable to prevent deadlock.
// For more on Sendable functions & closures, see:
// https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md#new-sendable-attribute-for-functions
func unsafeWaitFor(_ block: @Sendable @escaping () async -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    defer {
        semaphore.wait()
    }

    Task.detached {
        await block()
        semaphore.signal()
    }
}
