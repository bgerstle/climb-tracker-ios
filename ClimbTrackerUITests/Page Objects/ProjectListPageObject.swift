//
//  ClimbHistoryView.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/9/21.
//

import XCTest

class ProjectListPageObject {
    public let view: XCUIElement

    init(view: XCUIElement) {
        self.view = view
    }

    class Element {
        public let view: XCUIElement

        public init(view: XCUIElement) {
            self.view = view
        }

        var cellText: String {
            view.label
        }
    }

    var rows: [ProjectListPageObject.Element] {
        get {
            view.descendants(matching: .any)
                .matching(identifier: "projectListElement")
                .allElementsBoundByIndex
                .map( { ProjectListPageObject.Element(view: $0) })
        }
    }

    private var navigationBar: XCUIElement {
        view.navigationBars.firstMatch
    }
    
    var newProjectButton: XCUIElement {
        navigationBar
            // FIXME: accessibility identifier isn't being set for some reason
            .buttons
            .firstMatch
    }
}

extension XCUIApplication {
    var climbHistory: ProjectListPageObject {
        return ProjectListPageObject(
            view: descendants(matching: .any)
                .matching(identifier: "projectList")
                .firstMatch
        )
    }
}
