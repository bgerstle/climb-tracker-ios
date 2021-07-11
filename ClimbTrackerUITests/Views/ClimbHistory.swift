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

    var rows: [ClimbHistory.Row] {
        get {
            view.descendants(matching: .any)
                .matching(identifier: "climbHistoryRow")
                .allElementsBoundByIndex
                .map( { ClimbHistory.Row(view: $0) })
        }
    }

    var addClimbButton: XCUIElement {
        view.navigationBars
            .firstMatch
            .toolbarButtons.matching(identifier: "addClimbButton")
            .firstMatch
    }
}

extension XCUIApplication {
    var climbHistory: ClimbHistory {
        return ClimbHistory(view: descendants(matching: .any)
                                .matching(identifier: "climbHistoryList")
                                .firstMatch)
    }
}
