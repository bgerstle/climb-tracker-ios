//
//  AddProjectViewUITests.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/11/21.
//

import XCTest
import Quick

class AddProjectViewUITests: QuickSpec {
    var app: XCUIApplication!

    var projectList: ProjectListPageObject {
        app.projectList
    }

    var addProject: AddProjectPageObject {
        app.addProject
    }

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.app = XCUIApplication()
            self.app.launch()
        }

        describe("Adding a climb") {
            context("Given I am adding a climb") {
                beforeEach {
                    self.app.projectList.newProjectButton.tap()
                    XCTAssertTrue(self.projectList.view
                                    .waitForExistence(timeout: 2))
                }

                describe("When I log a bouldering send without changing any fields") {
                    it("Then I see a Boulder climb with the default grade") {
                        self.addProject.submitButton.tap()
                        
                        XCTAssertEqual(self.projectList.rows.count, 1)
                        let firstRow = self.projectList.rows.first!
                        XCTAssertTrue(firstRow.gradeLabelText.contains("VB"))
                        XCTAssertTrue(firstRow.titleLabelText.contains("Boulder"))
                    }
                }

                describe("When I swipe down") {
                    it("Then I am taken back to climb history") {
                        XCTAssertTrue(self.addProject.view
                                        .waitForExistence(timeout: 2))

                        self.app.swipeDown(velocity: .fast)

                        XCTAssertFalse(self.addProject.view.isHittable)

                        XCTAssertTrue(self.projectList.view
                                        .waitForExistence(timeout: 2))

                        XCTAssertTrue(self.app.projectList.view.isHittable)
                    }
                }

                describe("When I submit a climb with the default category and a custom grade") {
                    it("Then I see a new boulder climb with the grade I selected") {
                        let rawGradeValue = "V5"
                        let defaultCategory = "Boulder"

                        self.addProject.gradePicker.tap()
                        self.addProject.pickerOption(forRawValue: rawGradeValue).tap()
                        XCTAssertTrue(self.addProject.submitButton.isHittable)
                        self.addProject.submitButton.tap()

                        XCTAssertTrue(self.projectList.view
                                        .waitForExistence(timeout: 2))

                        XCTAssertEqual(self.projectList.rows.count, 1)

                        let firstRow = self.projectList.rows.first
                        XCTAssertTrue((firstRow?.gradeLabelText ?? "").contains(rawGradeValue))

                        XCTAssertTrue((firstRow?.titleLabelText ?? "").contains(defaultCategory))
                    }
                }

                describe("When I submit a climb with a custom category and a default grade") {
                    it("Then I see a new top rope climb with the default grade") {
                        let rawCategoryValue = "Rope"
                        let defaultGrade = "5.9"

                        self.addProject.categoryPicker.tap()
                        self.addProject.pickerOption(forRawValue: rawCategoryValue).tap()
                        XCTAssertTrue(self.addProject.submitButton.isHittable)
                        self.addProject.submitButton.tap()

                        XCTAssertTrue(self.projectList.view
                                        .waitForExistence(timeout: 2))

                        XCTAssertEqual(self.projectList.rows.count, 1)

                        let firstRow = self.projectList.rows.first
                        XCTAssertTrue((firstRow?.gradeLabelText ?? "").contains(defaultGrade))

                        XCTAssertTrue((firstRow?.titleLabelText ?? "").contains(rawCategoryValue))
                    }
                }

                describe("When I submit a climb with a custom category and a custom grade") {
                    it("Then I see a new climb with the custom grade and category") {
                        let rawCategoryValue = "Rope"
                        let rawGradeValue = "5.11a"

                        self.addProject.categoryPicker.tap()
                        self.addProject.pickerOption(forRawValue: rawCategoryValue).tap()
                        self.addProject.gradePicker.tap()
                        self.addProject.pickerOption(forRawValue: rawGradeValue).tap()
                        XCTAssertTrue(self.addProject.submitButton.isHittable)
                        self.addProject.submitButton.tap()

                        XCTAssertTrue(self.projectList.view
                                        .waitForExistence(timeout: 2))

                        XCTAssertEqual(self.projectList.rows.count, 1)

                        let firstRow = self.projectList.rows.first
                        XCTAssertTrue((firstRow?.gradeLabelText ?? "").contains(rawGradeValue))

                        XCTAssertTrue((firstRow?.titleLabelText ?? "").contains(rawCategoryValue))
                    }
                }
            }
        }
    }
}
