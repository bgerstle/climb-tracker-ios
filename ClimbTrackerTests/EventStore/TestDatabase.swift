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

    init(filename: String = "test_database") {
        self.tempDatabasePath = NSTemporaryDirectory().appending("\(filename).sqlite")
        super.init()
    }

    func testCaseWillStart(_ testCase: XCTestCase) {
        // delete any file left over from a crash
        try? FileManager.default.removeItem(atPath: tempDatabasePath)
        try! open()
        try! migrator.migrate(db)
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        try! tearDown()
    }

    func tearDown() throws {
        if db != nil {
            try! close()
            try? FileManager.default.removeItem(atPath: tempDatabasePath)
        }
    }

    func close() throws {
        try db.close()
        db = nil
    }

    func open() throws {
        db = try DatabasePool(path: tempDatabasePath)
    }

    static let eventStore: TestDatabase = {
        let testDB = TestDatabase(filename: "testEventStoreDB")
        testDB.migrator.setupEventStoreMigrations()
        return testDB
    }()
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
