//
//  ProjectDetailsUITests.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 12/10/21.
//

import XCTest

class ProjectDetailsUITests: XCTestCase, CanAddProject {
    var app: XCUIApplication!

    var projectListView: ProjectListPageObject {
        app.projectList
    }

    var addProjectView: AddProjectPageObject {
        app.addProject
    }

    var projectDetailsView: ProjectDetailsPageObject {
        app.projectDetailsView
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.resetDatabaseOnLaunch()
        app.launch()
    }

    func testGivenProjectAdded_CanNavigateToDetails() {
        addProject(category: nil, grade: nil)

        let firstRow = projectListView.rows.first
        firstRow?.view.tap()

        XCTAssertTrue(projectDetailsView.view.waitForExistence(timeout: 2.0))
    }
}
