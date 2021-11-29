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
        var imports = UserDefaults.standard.object(forKey: "imports") as? Array<AnyObject> ?? [AnyObject]()

        if imports.contains(where: { ($0 as? String) == filename }) {
            logger.info("Already imported \(filename)")
            return
        }

        let inputURL = Bundle.main.url(forResource: filename, withExtension: "csv")!

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

        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)


        imports.append(filename as NSString)
        UserDefaults.standard.set(imports, forKey: "imports")
        logger.info("Done importing \(filename)")
    }

    var body: some Scene {
        // FIXME remove try!
        let db = try! setupDatabase(),
            eventStore = try! PersistentEventStore(db: db),
            projectService = ProjectEventService(eventStore: eventStore),
            projectNameService = ProjectNameEventService(eventStore: eventStore),
            summarizer: ProjectSummarizer = ProjectSummarizer(),
            projectListViewModel = ProjectListViewModel(projectService: projectService)

        if !ProcessInfo.processInfo.isTesting {
            if CommandLine.arguments.contains("-resetDatabase") {
                try! resetDatabase()
            }

            try! importCSV(projectService: projectService, projectNameService: projectNameService)
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
