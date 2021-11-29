//
//  CSVImporter.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/26/21.
//

import Foundation
import CodableCSV
import os

protocol CSVImportable {
    var date: Date { get }

    var countAttempts: Int { get }

    var name: String? { get }

    var projectCategory: ProjectCategory { get }

    var grade: String { get }

    var ropeSubcategory: RopeProject.Subcategory? { get }

    var didSend: Bool { get }

    static func parse(_ url: URL) throws -> [Self]
}

extension CSVImportable {
    var boulderGrade: AnyBoulderGrade? {
        AnyBoulderGrade(rawValue: grade)
    }

    var ropeGrade: AnyRopeGrade? {
        AnyRopeGrade(rawValue: grade)
    }
}

class CSVImporter<Row: CSVImportable> {
    let logger = Logger.app(category: "csvImport")

    enum CSVImportError : Error {
        case invalidGrade(grade: String),
             missingSubcategory
    }

    let projectSevice: ProjectService
    let projectNameService: ProjectNameService

    init(projectService: ProjectService, projectNameService: ProjectNameService) {
        self.projectSevice = projectService
        self.projectNameService = projectNameService
    }

    // TODO: make idempotent
    // wrap everything in 1 database transaction/savepoint & use db to record that the file was imported
    func importCSV(_ url: URL) async throws {
        let rows = try Row.parse(url)

        for (number, row) in rows.enumerated() {
            logger.info("importing row \(number)")
            try await self.importRow(row)
        }
    }

    func importRow(_ row: Row) async throws {
        let projectId = try await findOrCreateProjectIfNeeded(name: row.name, grade: row.grade, category: row.projectCategory)

        for attemptNumber in (0..<row.countAttempts) {
            let isLastAttempt = attemptNumber == row.countAttempts - 1,
                didSend = row.didSend && isLastAttempt

            switch row.projectCategory {
            case .boulder:
                logger.info("Adding boulder attempt for \(projectId)")
                try await projectSevice.attempt(projectId: projectId,
                                                at: row.date,
                                                didSend: didSend)
            case .rope:
                guard let subcategory = row.ropeSubcategory else {
                    throw CSVImportError.missingSubcategory
                }
                logger.info("Adding \(subcategory.rawValue) attempt for \(projectId)")
                switch subcategory {
                case .topRope:
                    logger.info("Adding top rope attempt for \(projectId)")
                    try await projectSevice.attempt(projectId: projectId,
                                                    at: row.date,
                                                    didSend: didSend,
                                                    subcategory: .topRope)
                case .sport:

                    try await projectSevice.attempt(projectId: projectId,
                                                    at: row.date,
                                                    didSend: didSend,
                                                    subcategory: .sport)
                }
            }
        }
    }

    func findOrCreateProjectIfNeeded(name: String?, grade: String, category: ProjectCategory) async throws -> ProjectID {
        if let name = name {
            if let projectId = try await projectNameService.getProject(forName: name) {
                logger.info("Project \(projectId) exists with name \(name)")
                return projectId
            }
        }

        logger.info("Creating project with name \(String(describing: name)) and grade \(grade)")

        switch category {
        case .boulder:
            guard let boulderGrade = AnyBoulderGrade(rawValue: grade) else {
                throw CSVImportError.invalidGrade(grade: grade)
            }
            switch boulderGrade {
            case .hueco(let huecoGrade):
                return try await projectNameService.createProject(grade: huecoGrade, name: name, withFactory: self.projectSevice.create)
            case .font(let fontGrade):
                return try await projectNameService.createProject(grade: fontGrade, name: name, withFactory: self.projectSevice.create)
            }
        case .rope:
            guard let ropeGrade = AnyRopeGrade(rawValue: grade) else {
                throw CSVImportError.invalidGrade(grade: grade)
            }
            switch ropeGrade {
            case .yosemite(let yosemiteDecimalGrade):
                return try await projectNameService.createProject(grade: yosemiteDecimalGrade, name: name, withFactory: self.projectSevice.create)
            case .french(let frenchGrade):
                return try await projectNameService.createProject(grade: frenchGrade, name: name, withFactory: self.projectSevice.create)
            }
        }

    }
}
