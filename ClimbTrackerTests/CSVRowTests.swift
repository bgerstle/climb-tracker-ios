//
//  CSVRowTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/27/21.
//

import XCTest
@testable import ClimbTracker
import CodableCSV

extension Calendar {
    func components(withYear year: Int, month: Int, day: Int) -> DateComponents {
        var components = DateComponents()
        components.calendar = self
        components.year = year
        components.month = month
        components.day = day
        return components
    }
}

class CSVRowTests: XCTestCase {
    func testDateFormatter() {
        // !!!: using double-digit month & day to avoid zero padding
        let components = Calendar.current.components(withYear: 2019, month: 12, day: 10)
        let expectedDate = Calendar.current.date(from: components)!

        XCTAssertEqual(DateFormatter.hyphenatedDate.string(from: expectedDate),
                       "\(components.year!)-\(components.month!)-\(components.day!)")
    }

    func testDecode() throws {
        let expectedDate = Calendar.current.date(from: Calendar.current.components(withYear: 2019,
                                                                                   month: 8,
                                                                                   day: 6))!

        let csv = """
date,category,grade,send,attempts,name
2019-08-06,bouldering,V1,on-site,1,warmup v1 8-6
"""
        let decoder = CSVDecoder.importDecoder()

        let rows = try decoder.decode([CSVRow].self, from: csv)
        let row = rows.first!

        XCTAssertEqual(row.date, expectedDate)
        XCTAssertEqual(row.category, .bouldering)
        XCTAssertEqual(row.grade, "V1")
        XCTAssertEqual(row.attempts, 1)
        XCTAssertEqual(row.send, "on-site")
        XCTAssertEqual(row.name, "warmup v1 8-6")
    }

    func testDecodeQuotedValues() throws {
        let expectedDate = Calendar.current.date(from: Calendar.current.components(withYear: 2019,
                                                                                   month: 8,
                                                                                   day: 29))!

        let csv = """
date,category,grade,send,attempts,name
2019-08-29,bouldering,V3,no,4,"Black, pinchy, ""1"" volume V3"
"""
        let decoder = CSVDecoder.importDecoder()

        let rows = try decoder.decode([CSVRow].self, from: csv)
        let row = rows.first!

        XCTAssertEqual(row.date, expectedDate)
        XCTAssertEqual(row.category, .bouldering)
        XCTAssertEqual(row.grade, "V3")
        XCTAssertEqual(row.attempts, 4)
        XCTAssertEqual(row.send, "no")
        XCTAssertEqual(row.name, "Black, pinchy, \"1\" volume V3")
    }

    func testDecodeWithoutName() throws {
        let expectedDate = Calendar.current.date(from: Calendar.current.components(withYear: 2021,
                                                                                   month: 5,
                                                                                   day: 20))!

        let csv = """
date,category,grade,send,attempts,name
2021-05-20,top rope,5.9,onsight,1,
"""
        let decoder = CSVDecoder.importDecoder()

        let rows = try decoder.decode([CSVRow].self, from: csv)
        let row = rows.first!

        XCTAssertEqual(row.date, expectedDate)
        XCTAssertEqual(row.category, .topRope)
        XCTAssertEqual(row.grade, "5.9")
        XCTAssertEqual(row.attempts, 1)
        XCTAssertEqual(row.send, "onsight")
        XCTAssertNil(row.name)
    }

    func testDecodeWithoutNameSendOrAttempt_DefaultsToSendWithOneAttempt() throws {
        let expectedDate = Calendar.current.date(from: Calendar.current.components(withYear: 2021,
                                                                                   month: 5,
                                                                                   day: 20))!

        let csv = """
date,category,grade,send,attempts,name
2021-05-20,bouldering,V0,,,
"""
        let decoder = CSVDecoder.importDecoder()

        let rows = try decoder.decode([CSVRow].self, from: csv)
        let row = rows.first!

        XCTAssertEqual(row.date, expectedDate)
        XCTAssertEqual(row.category, .bouldering)
        XCTAssertEqual(row.grade, "V0")
        XCTAssertNil(row.attempts)
        XCTAssertEqual(row.countAttempts, 1)
        XCTAssertEqual(row.send, nil)
        XCTAssertEqual(row.didSend, true)
        XCTAssertNil(row.name)
    }

    func testDecodeExampleFile() throws {
        let inputURL = Bundle(for: Self.self).url(forResource: "export_2019_to_2021_05_23", withExtension: "csv")!
        let decoder = CSVDecoder.importDecoder()

        let rows = try decoder.decode([CSVRow].self, from: inputURL)

        // rows == lines - 1 (header row)
        XCTAssertEqual(rows.count, 1351)
    }
}
