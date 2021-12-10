//
//  CanAddProject.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 12/10/21.
//

import XCTest

protocol CanAddProject {
    var projectListView: ProjectListPageObject { get }

    var addProjectView: AddProjectPageObject { get }
}

extension CanAddProject {
    func addProject(category: String? = nil, grade: String? = nil) {
        XCTAssertTrue(projectListView.newProjectButton.waitForExistence(timeout: 2),
                      "Must call this from the project list.")

        projectListView.newProjectButton.tap()

        XCTAssertTrue(addProjectView.view.waitForExistence(timeout: 2))

        if let category = category {
            addProjectView.categoryPicker.tap()
            addProjectView.pickerOption(forRawValue: category).tap()
        }

        if let grade = grade {
            addProjectView.gradePicker.tap()
            addProjectView.pickerOption(forRawValue: grade).tap()
        }

        addProjectView.submitButton.tap()

        XCTAssertTrue(projectListView.view.waitForExistence(timeout: 2))
    }
}
