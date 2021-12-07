//
//  CSVImporterTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/29/21.
//

import XCTest
@testable import ClimbTracker

class CSVImporterTests: XCTestCase {
    var importer: CSVImporter<CSVRow>!
    var projectNameService: TestProjectNameService!
    var projectService: TestProjectService!

    override func setUpWithError() throws {
        projectService = TestProjectService()
        projectNameService = TestProjectNameService()
        importer = CSVImporter(projectService: projectService, projectNameService: projectNameService)
    }

    func testImportRow_GivenNoName_WhenImported_CreatesProjectWithoutName() async throws {
        let row = CSVRow(
            date: Date(),
            category: .topRope,
            grade: YosemiteDecimalGrade.elevenA.rawValue,
            send: "",
            attempts: 0,
            name: nil
        )

        try await importer.importRow(row)

        let createdProjects = await projectService.projects.values
        XCTAssertEqual(createdProjects.count, 1)

        guard let importedProject: AnyProject = createdProjects.first else { XCTFail(); return }
        XCTAssertEqual(importedProject.category, ProjectCategory.rope)
        XCTAssertEqual(importedProject.rawGrade, row.grade)

        let addedAttempts = await projectService.attempts.values
        XCTAssertEqual(addedAttempts.count, 0)

        let projectNames = await projectNameService.names
        XCTAssertEqual(projectNames.count, 0)
    }

    func testImportRow_GivenName_WhenImported_CreatesProjectWithName() async throws {
        let row = CSVRow(
            date: Date(),
            category: .topRope,
            grade: YosemiteDecimalGrade.elevenA.rawValue,
            send: "",
            attempts: 0,
            name: "foo"
        )

        try await importer.importRow(row)

        let createdProjects = await projectService.projects.values
        XCTAssertEqual(createdProjects.count, 1)

        guard let importedProject: AnyProject = createdProjects.first else { XCTFail(); return }
        XCTAssertEqual(importedProject.category, ProjectCategory.rope)
        XCTAssertEqual(importedProject.rawGrade, row.grade)

        let addedAttempts = await projectService.attempts.values
        XCTAssertEqual(addedAttempts.count, 0)

        let projectNames = await projectNameService.names
        XCTAssertEqual(projectNames.count, 1)

        guard let projectName = try await projectNameService.getName(forProject: importedProject.id) else { XCTFail(); return }
        XCTAssertEqual(projectName, row.name)
    }

    func testImportRow_GivenOneAttempt_AndSendIsNo_WhenImported_CreatesProjectAndAddsAnAttempt_AndDidSendIsFalse() async throws {
        let row = CSVRow(
            date: Date(),
            category: .topRope,
            grade: YosemiteDecimalGrade.elevenA.rawValue,
            send: "no",
            attempts: 1,
            name: nil
        )

        try await importer.importRow(row)

        let createdProjects = await projectService.projects.values
        XCTAssertEqual(createdProjects.count, 1)

        guard let importedProject: AnyProject = createdProjects.first else { XCTFail(); return }
        XCTAssertEqual(importedProject.category, ProjectCategory.rope)
        XCTAssertEqual(importedProject.rawGrade, row.grade)

        guard let addedAttempts = await projectService.attempts[importedProject.id] else {
            XCTFail("No attempts found for project \(importedProject.id)"); return
        }
        XCTAssertEqual(addedAttempts.count, 1)

        guard let anyAttempt: AnyAttempt = addedAttempts.first else { XCTFail(); return }
        XCTAssertEqual(anyAttempt.didSend, false)
        XCTAssertEqual(anyAttempt.attemptedAt, row.date)

        guard let ropeAttempt = anyAttempt as? RopeProject.Attempt else {
            XCTFail("Expected rope attempt but got \(anyAttempt)"); return
        }
        XCTAssertEqual(ropeAttempt.subcategory, .topRope)
    }

    func testImportRow_GivenMultipleAttempt_AndSendIsNotNo_WhenImported_CreatesProjectAndAddsEachAttempt_AndDidSendIsTrueOnLastAttemptOnly() async throws {
        let row = CSVRow(
            date: Date(),
            category: .lead,
            grade: YosemiteDecimalGrade.elevenA.rawValue,
            send: "yes",
            attempts: 3,
            name: nil
        )

        try await importer.importRow(row)

        let createdProjects = await projectService.projects.values
        XCTAssertEqual(createdProjects.count, 1)

        guard let importedProject: AnyProject = createdProjects.first else { XCTFail(); return }
        XCTAssertEqual(importedProject.category, ProjectCategory.rope)
        XCTAssertEqual(importedProject.rawGrade, row.grade)

        guard let addedAttempts = await projectService.attempts[importedProject.id] else {
            XCTFail("No attempts found for project \(importedProject.id)"); return
        }
        XCTAssertEqual(addedAttempts.count, row.countAttempts)

        guard let ropeAttempts = addedAttempts as? [RopeProject.Attempt] else {
            XCTFail("Expected rope attempt but got \(addedAttempts)"); return
        }
        XCTAssertEqual(Set(ropeAttempts.map(\.subcategory)), Set([.sport]))
        XCTAssertEqual(Set(ropeAttempts.map(\.attemptedAt)), Set([row.date]))
        XCTAssertEqual(ropeAttempts.map(\.didSend), [false, false, true])
    }

    func testImportRow_GivenRecurringName_WhenImported_AddsAttemptsWithoutCreating() async throws {
        let row = CSVRow(
            date: Date(),
            category: .lead,
            grade: YosemiteDecimalGrade.elevenA.rawValue,
            send: "no",
            attempts: 3,
            name: "foo"
        ),
            repeatRow = CSVRow(
            date: row.date.advanced(by: 1),
            category: row.category,
            grade: row.grade,
            send: "yes",
            attempts: 1,
            name: row.name
        )

        try await importer.importRow(row)
        try await importer.importRow(repeatRow)

        let createdProjects = await projectService.projects.values
        XCTAssertEqual(createdProjects.count, 1)

        guard let importedProject: AnyProject = createdProjects.first else { XCTFail(); return }
        XCTAssertEqual(importedProject.category, ProjectCategory.rope)
        XCTAssertEqual(importedProject.rawGrade, row.grade)

        guard let addedAttempts = await projectService.attempts[importedProject.id] else {
            XCTFail("No attempts found for project \(importedProject.id)"); return
        }
        XCTAssertEqual(addedAttempts.count, row.countAttempts + repeatRow.countAttempts)

        guard let ropeAttempts = addedAttempts as? [RopeProject.Attempt] else {
            XCTFail("Expected rope attempt but got \(addedAttempts)"); return
        }
        XCTAssertEqual(Set(ropeAttempts.map(\.subcategory)), Set([.sport]))
        XCTAssertEqual(Set(ropeAttempts.map(\.attemptedAt)), Set([row.date, repeatRow.date]))
        let expectedAttemptSendStatuses =
            Array(repeating: false, count: row.countAttempts)
            + Array(repeating: true, count: repeatRow.countAttempts)
        XCTAssertEqual(ropeAttempts.map(\.didSend), expectedAttemptSendStatuses)
    }
}
