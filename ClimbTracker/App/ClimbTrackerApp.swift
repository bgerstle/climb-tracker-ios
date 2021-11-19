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
    func setupDatabase() throws -> DatabasePool {
        // TODO: show error page if this fails
        let dbPath = Bundle.main
                           .resourceURL!
                           .appendingPathComponent("database.sqlite")
                           .absoluteString,
            db = try DatabasePool(path: dbPath)

        var migrator = DatabaseMigrator()
        migrator.setupEventStoreMigrations()

        try migrator.migrate(db)

        return db
    }

    var body: some Scene {
        let db = try! setupDatabase(),
            // FIXME
            _ = try! PersistentEventStore(db: db),
            eventStore = EphemeralEventStore(),
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
