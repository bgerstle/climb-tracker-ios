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
    let csvImportManager = CSVImportManager()

    var body: some Scene {
        // FIXME: remove try!
        let db = try! dbManager.setupDatabase(),
            eventStore = try! PersistentEventStore(db: db),
            projectService = ProjectEventService(eventStore: eventStore),
            projectNameService = ProjectNameEventService(eventStore: eventStore),
            summarizer: ProjectSummarizer = ProjectSummarizer(),
            projectListViewModel = ProjectListViewModel(projectService: projectService)

        if !ProcessInfo.processInfo.isTesting {
            if CommandLine.arguments.contains("-resetDatabase") {
                try! dbManager.resetDatabase()
            }

            // TODO: proper async importing & UI
            // if I try to extract this, it deadlocks?!
            let semaphore = DispatchSemaphore(value: 0)

            Task.detached {
                try! await self.csvImportManager.importCSV(projectService: projectService, projectNameService: projectNameService)
                semaphore.signal()
            }

            semaphore.wait()

            let summaryEventPublisher = summarizer.summarizeProjectEvents(
                boulder: projectService.boulderProjectEventPublisher,
                rope: projectService.ropeProjectEventPublisher,
                name: projectNameService.projectNamedEventPublisher
            )
            projectListViewModel.handleSummaryEvents(summaryEventPublisher)
        }

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
