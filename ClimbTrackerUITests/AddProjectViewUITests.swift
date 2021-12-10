//
//  AddProjectViewUITests.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/11/21.
//

import XCTest
import Quick

class AddProjectViewUITests: QuickSpec, CanAddProject {
    var app: XCUIApplication!

    var projectListView: ProjectListPageObject {
        app.projectList
    }

    var addProjectView: AddProjectPageObject {
        app.addProject
    }

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.app = XCUIApplication()
            self.app.resetDatabaseOnLaunch()
            self.app.launch()
        }

        describe("Adding a climb") {
            context("Given I am adding a climb") {
                describe("When I log a bouldering send without changing any fields") {
                    it("Then I see a Boulder climb with the default grade") {
                        self.addProject(category: nil, grade: nil)
                        
                        XCTAssertEqual(self.projectListView.rows.count, 1)
                        let firstRow = self.projectListView.rows.first!
                        XCTAssertTrue(firstRow.gradeLabelText.contains("VB"))
                    }
                }

                describe("When I swipe down") {
                    it("Then I am taken back to climb history") {
                        self.projectListView.newProjectButton.tap()

                        XCTAssertTrue(self.addProjectView.view
                                        .waitForExistence(timeout: 2))

                        self.app.swipeDown(velocity: .fast)

                        XCTAssertFalse(self.addProjectView.view.isHittable)

                        XCTAssertTrue(self.projectListView.view
                                        .waitForExistence(timeout: 2))

                        XCTAssertTrue(self.app.projectList.view.isHittable)
                    }
                }

                describe("When I submit a climb with the default category and a custom grade") {
                    it("Then I see a new boulder climb with the grade I selected") {
                        let rawGradeValue = "V5"
                        self.addProject(category: nil, grade: rawGradeValue)

                        XCTAssertEqual(self.projectListView.rows.count, 1)

                        let firstRow = self.projectListView.rows.first
                        XCTAssertTrue((firstRow?.gradeLabelText ?? "").contains(rawGradeValue))
                    }
                }

                describe("When I submit a climb with a custom category and a default grade") {
                    it("Then I see a new top rope climb with the default grade") {
                        let rawCategoryValue = "Rope"
                        let defaultGrade = "5.9"

                        self.addProject(category: rawCategoryValue, grade: nil)

                        XCTAssertEqual(self.projectListView.rows.count, 1)

                        let firstRow = self.projectListView.rows.first
                        XCTAssertTrue((firstRow?.gradeLabelText ?? "").contains(defaultGrade))
                    }
                }

                describe("When I submit a climb with a custom category and a custom grade") {
                    it("Then I see a new climb with the custom grade and category") {
                        let rawCategoryValue = "Rope"
                        let rawGradeValue = "5.11a"

                        self.addProject(category: rawCategoryValue, grade: rawGradeValue)

                        XCTAssertEqual(self.projectListView.rows.count, 1)

                        let firstRow = self.projectListView.rows.first
                        XCTAssertTrue((firstRow?.gradeLabelText ?? "").contains(rawGradeValue))
                    }
                }

                it("When I restart, then the climbs are still in the list") {
                    let rawCategoryValue = "Rope"
                    let rawGradeValue = "5.12b"

                    self.addProject(category: rawCategoryValue, grade: rawGradeValue)

                    self.app.terminate()
                    // remove "resetDatabase" launch arg
                    self.app.launchArguments.removeAll()
                    self.app.launch()

                    XCTAssertTrue(self.projectListView.view.waitForExistence(timeout: 2))
                    XCTAssertEqual(self.projectListView.rows.count, 1)

                    let firstRow = self.projectListView.rows.first
                    XCTAssertTrue((firstRow?.gradeLabelText ?? "").contains(rawGradeValue))
                }
            }
        }
    }
}
