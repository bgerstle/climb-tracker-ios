//
//  ClimbTrackerApp.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/2/21.
//

import SwiftUI
import Combine
import GRDB

@main
struct ClimbTrackerApp: App {
    enum DBSetupError : Error {
        case pathNotFound(path: String)
    }

    func databasePath() throws -> String {
        try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
            .path
    }

    func setupDatabase() throws -> DatabasePool {
        // TODO: show error page if this fails
        let dbPath = try databasePath(),
        db = try DatabasePool(path: dbPath)

        var migrator = DatabaseMigrator()
        migrator.setupEventStoreMigrations()

        try migrator.migrate(db)

        return db
    }

    func resetDatabase() throws {
        let dbPath = try databasePath()

        try FileManager.default.removeItem(atPath: dbPath)
    }

    var body: some Scene {
        if CommandLine.arguments.contains("-resetDatabase") {
            try! resetDatabase()
        }

        // FIXME remove try!
        let db = try! setupDatabase(),
            eventStore = try! PersistentEventStore(db: db),
            projectService = ProjectEventService(eventStore: eventStore),
            projectNameService = ProjectNameEventService(eventStore: eventStore),
            summarizer: ProjectSummarizer = ProjectSummarizer(),
            summaryEventPublisher = summarizer.summarizeProjectEvents(
                boulder: projectService.boulderProjectEventPublisher,
                rope: projectService.ropeProjectEventPublisher,
                name: projectNameService.projectNamedEventPublisher
            ),
            projectListViewModel = ProjectListViewModel(projectService: projectService)

        projectListViewModel.handleSummaryEvents(summaryEventPublisher)

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
