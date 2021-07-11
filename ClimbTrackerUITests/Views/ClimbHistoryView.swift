//
//  ClimbHistoryView.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/9/21.
//

import XCTest

class ClimbHistoryPage {
    public let view: XCUIElement

    init(view: XCUIElement) {
        self.view = view
    }
}

extension XCUIApplication {
    var climbHistoryView: ClimbHistoryPage {
        return ClimbHistoryPage(view: tables.matching(identifier: "climbHistoryList").firstMatch)
    }
}

class ClimbHistoryRow {
    public let view: XCUIElement

    public init(view: XCUIElement) {
        self.view = view
    }
}

extension ClimbHistoryPage {
    var rows: [ClimbHistoryRow] {
        get {
            view.descendants(matching: .any)
                .matching(identifier: "climbHistoryRow")
                .allElementsBoundByIndex
                .map( { ClimbHistoryRow(view: $0) })
        }
    }
}
