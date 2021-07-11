//
//  ClimbHistoryView.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/9/21.
//

import XCTest

class ClimbHistory {
    public let view: XCUIElement
    private let navigationBar: XCUIElement

    init(view: XCUIElement, navigationBar: XCUIElement) {
        self.view = view
        self.navigationBar = navigationBar
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

    var logClimbButton: XCUIElement {
        navigationBar
            .buttons
            .matching(identifier: "logClimbButton")
            .firstMatch
    }
}

extension XCUIApplication {
    var climbHistory: ClimbHistory {
        let historyView =
            descendants(matching: .any)
                .matching(identifier: "climbHistoryList")
                .firstMatch
        let navigationBar = navigationBars.firstMatch
        return ClimbHistory(view: historyView, navigationBar: navigationBar)
    }
}
