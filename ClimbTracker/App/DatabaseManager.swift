//
//  DatabaseManager.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/29/21.
//

import Foundation
import GRDB

class DatabaseManager {
    enum SetupError : Error {
        case pathNotFound(path: String)
    }

    private var migrator = DatabaseMigrator()

    private func databasePath() throws -> String {
        try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
            .path
    }

    func setupDatabase() throws -> DatabasePool {
        // TODO: show error page if this fails
        let dbPath = try databasePath(),
            db = try DatabasePool(path: dbPath)

        migrator.setupEventStoreMigrations()

        try migrator.migrate(db)

        return db
    }

    func resetDatabase() throws {
        guard FileManager.default.fileExists(atPath: try databasePath()) else { return }
        try FileManager.default.removeItem(atPath: try databasePath())
    }
}
