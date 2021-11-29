//
//  CSVRow.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/29/21.
//

import Foundation
import CodableCSV

enum CSVCategory : String, CaseIterable, Codable {
    case bouldering,
    topRope = "top rope",
    lead
}

struct CSVRow : Hashable, Codable, CSVImportable {

    let date: Date
    let category: CSVCategory
    let grade: String
    let send: String?
    let attempts: Int?
    let name: String?

    var countAttempts: Int {
        attempts ?? 1
    }

    var projectCategory: ProjectCategory {
        switch category {
        case .bouldering:
            return .boulder
        case .topRope:
            return .rope
        case .lead:
            return .rope
        }
    }

    var ropeSubcategory: RopeProject.Subcategory? {
        switch category {
        case .bouldering:
            return nil
        case .topRope:
            return .topRope
        case .lead:
            return .sport
        }
    }

    var didSend: Bool {
        send.map { $0 != "no" } ?? true
    }

    static func parse(_ url: URL) throws -> [CSVRow] {
        try CSVDecoder.importDecoder().decode([Self].self, from: url)
    }
}

extension DateFormatter {
    static var hyphenatedDate: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.calendar = Calendar.current
        return dateFormatter
    }
}

extension CSVDecoder {
    static func importDecoder() -> CSVDecoder {
        CSVDecoder() {
            $0.headerStrategy = Strategy.Header.firstLine
            $0.trimStrategy = CharacterSet.whitespaces.union(CharacterSet(charactersIn: "\r"))
            $0.bufferingStrategy = .sequential
            $0.delimiters.row = "\n"
            $0.delimiters.field = ","
            $0.nilStrategy = .empty

            $0.dateStrategy = Strategy.DateDecoding.formatted(DateFormatter.hyphenatedDate)
        }
    }
}
