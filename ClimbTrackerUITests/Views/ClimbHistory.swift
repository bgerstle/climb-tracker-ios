//
//  ClimbHistoryView.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/9/21.
//

import XCTest

class ClimbHistory {
    public let view: XCUIElement

    init(view: XCUIElement) {
        self.view = view
    }

    class Row {
        public let view: XCUIElement

        public init(view: XCUIElement) {
            self.view = view
        }
    }
}

extension XCUIApplication {
    var climbHistory: ClimbHistory {
        return ClimbHistory(view: tables.matching(identifier: "climbHistoryList").firstMatch)
    }
}

extension ClimbHistory {
    var rows: [ClimbHistory.Row] {
        get {
            view.descendants(matching: .any)
                .matching(identifier: "climbHistoryRow")
                .allElementsBoundByIndex
                .map( { ClimbHistory.Row(view: $0) })
        }
    }
}
