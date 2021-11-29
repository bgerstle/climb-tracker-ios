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

@main
struct ClimbTrackerApp: App {
    enum DBSetupError : Error {
        case pathNotFound(path: String)
    }

    let logger = Logger.app(category: "main")

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

    func importCSV(projectService: ProjectService, projectNameService: ProjectNameService) throws {
        let filename = "export_2019_to_2021_05_23"
        guard let inputURL = Bundle.main.url(forResource: filename, withExtension: "csv"), !FileManager.default.fileExists(atPath: inputURL.absoluteString) else {
            logger.info("Already imported \(filename)")
            return
        }

        let importer = CSVImporter<CSVRow>(projectService: projectService,
                                           projectNameService: projectNameService)

        let semaphore = DispatchSemaphore(value: 0)

        Task.detached {
            logger.info("Importing \(filename)")
            do {
                try await importer.importCSV(inputURL)
            } catch {
                logger.fault("Failed to import CSV \(error.localizedDescription)")
            }
            semaphore.signal()
        }

        let _ = semaphore.wait(timeout: DispatchTime.now().advanced(by: .seconds(30)))

        logger.info("Done importing \(filename)")
        try FileManager.default.removeItem(at: inputURL)
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

        if !ProcessInfo.processInfo.isTesting {
            try! importCSV(projectService: projectService, projectNameService: projectNameService)
        }

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
