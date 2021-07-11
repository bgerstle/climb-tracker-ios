//
//  ClimbHistoryView.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/9/21.
//

import XCTest

class ClimbHistoryView {
    public let view: XCUIElement

    init(view: XCUIElement) {
        self.view = view
    }
}

extension XCUIApplication {
    var climbHistoryView: ClimbHistoryView {
        return ClimbHistoryView(view: tables.matching(identifier: "climbHistoryList").firstMatch)
    }
}

class ClimbHistoryRow {
    public let view: XCUIElement

    public init(view: XCUIElement) {
        self.view = view
    }
}

extension ClimbHistoryView {
    var rows: [ClimbHistoryRow] {
        get {
            view.descendants(matching: .any)
                .matching(identifier: "climbHistoryRow")
                .allElementsBoundByIndex
                .map( { ClimbHistoryRow(view: $0) })
        }
    }
}
