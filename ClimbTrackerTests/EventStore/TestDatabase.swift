//
//  TestDatabase.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/19/21.
//

import Foundation
import GRDB
import XCTest
@testable import ClimbTracker

class TestDatabase : NSObject, XCTestObservation {
    var db: DatabaseWriter!
    var migrator: DatabaseMigrator = DatabaseMigrator()
    let tempDatabasePath: String

    static func defaultPath() -> String {
        NSTemporaryDirectory().appending("test_database.sqlite")
    }

    init(tempDatabasePath: String = defaultPath()) {
        self.tempDatabasePath = tempDatabasePath
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    func testCaseWillStart(_ testCase: XCTestCase) {
        // delete any file left over from a crash
        try? FileManager.default.removeItem(atPath: tempDatabasePath)
        db = try! DatabasePool(path: tempDatabasePath)
        try! migrator.migrate(db)
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        // would be more efficient to set up once & delete all records between tests,
        // but I can't figure out how to easily delete rows from all tables. db.erase seems
        // to nuke everything

        try! db.close()
        db = nil
        try? FileManager.default.removeItem(atPath: tempDatabasePath)
    }

    static func eventStore() -> TestDatabase {
        let testDB = TestDatabase()
        testDB.migrator.setupEventStoreMigrations()
        return testDB
    }
}

// Date is (at least) nanosecond precision, but DATETIME is at most millisecond.
// To prevent false negatives in testing, initialize expected values with truncated Dates, preferably
// truncatedToSeconds(), since it seems like rounding errors can still cause false negatives after
// a round trip to/from the database when testing for strict equality.
extension Date {
    func truncatedToMilliseconds() -> Date {
        return Date(timeIntervalSince1970: floor(timeIntervalSince1970 * 1000) / 1000)
    }

    func truncatedToSeconds() -> Date {
        return Date(timeIntervalSince1970: floor(timeIntervalSince1970))
    }
}
