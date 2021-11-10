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

        var gradeLabelText: String {
            view.staticTexts
                .matching(identifier: "projectListElementGrade")
                .firstMatch
                .label
        }

        var titleLabelText: String {
            view.staticTexts
                .matching(identifier: "projectListElementTitle")
                .firstMatch
                .label
        }
    }

    var addAttemptSwipeAction: XCUIElement {
        view.descendants(matching: .any)
            .matching(identifier: "addProjectAttemptAction")
            .element
    }

    var addSendSwipeAction: XCUIElement {
        view.descendants(matching: .any)
            .matching(identifier: "addProjectSendAction")
            .element
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
