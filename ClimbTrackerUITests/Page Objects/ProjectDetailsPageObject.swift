//
//  ProjectDetailsPageObject.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 12/10/21.
//

import XCTest

struct ProjectDetailsPageObject {
    let view: XCUIElement
}

extension XCUIApplication {
    var projectDetailsView: ProjectDetailsPageObject {
        let view = descendants(matching: .any).matching(identifier: "projectDetailsView").firstMatch
        return ProjectDetailsPageObject(view: view)
    }
}
