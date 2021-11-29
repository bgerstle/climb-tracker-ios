//
//  CSVImportManager.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/29/21.
//

import Foundation
import os
import Combine

class CSVImportManager {
    let logger = Logger.app(category: "csvImportManager")

    func importCSV(projectService: ProjectService, projectNameService: ProjectNameService) async throws {
        let filename = "export_2019_to_2021_05_23"
        var imports = UserDefaults.standard.object(forKey: "imports") as? Array<AnyObject> ?? [AnyObject]()

        if imports.contains(where: { ($0 as? String) == filename }) {
            logger.info("Already imported \(filename)")
            return
        }

        let inputURL = Bundle.main.url(forResource: filename, withExtension: "csv")!

        let importer = CSVImporter<CSVRow>(projectService: projectService,
                                           projectNameService: projectNameService)

        self.logger.info("Importing \(filename)")
        do {
            try await importer.importCSV(inputURL)
        } catch {
            self.logger.error("Failed to import CSV \(String(describing: error))")
        }

        imports.append(filename as NSString)
        UserDefaults.standard.set(imports, forKey: "imports")
        logger.info("Done importing \(filename)")
    }
}
