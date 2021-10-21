//
//  AddClimbViewUITests.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/11/21.
//

import XCTest
import Quick

class AddClimbViewUITests: QuickSpec {
    var app: XCUIApplication!

    var climbHistory: ClimbHistory {
        app.climbHistory
    }

    var addClimb: AddClimb {
        app.addClimb
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
                    self.app.climbHistory.addClimbButton.tap()
                    XCTAssertTrue(self.climbHistory.view
                                    .waitForExistence(timeout: 2))
                }

                describe("When I log a bouldering send without changing any fields") {
                    it("Then I see a Boulder climb with the default grade") {
                        self.addClimb.submitButton.tap()
                        
                        XCTAssertEqual(self.climbHistory.rows.count, 1)
                        let firstRow = self.climbHistory.rows.first!
                        XCTAssertTrue(firstRow.cellText.contains("VB"))
                        XCTAssertTrue(firstRow.cellText.contains("Boulder"))
                    }
                }

                describe("When I swipe down") {
                    it("Then I am taken back to climb history") {
                        self.app.swipeDown()

                        XCTAssertFalse(self.addClimb.view.isHittable)
                        XCTAssertTrue(self.app.climbHistory.view.isHittable)
                    }
                }

                describe("When I submit a climb with the default category and a custom grade") {
                    it("Then I see a new boulder climb with the grade I selected") {
                        let rawGradeValue = "V5"
                        let defaultCategory = "Boulder"

                        self.addClimb.gradePicker.tap()
                        self.addClimb.pickerOption(forRawValue: rawGradeValue).tap()
                        XCTAssertTrue(self.addClimb.submitButton.isHittable)
                        self.addClimb.submitButton.tap()

                        XCTAssertTrue(self.climbHistory.view
                                        .waitForExistence(timeout: 2))

                        XCTAssertEqual(self.climbHistory.rows.count, 1)

                        let firstRowText = self.climbHistory.rows.first.map(\.cellText) ?? ""
                        XCTAssertTrue(firstRowText.contains(rawGradeValue))
                        XCTAssertTrue(firstRowText.contains(defaultCategory))
                    }
                }

                describe("When I submit a climb with a custom category and a default grade") {
                    it("Then I see a new top rope climb with the default grade") {
                        let rawCategoryValue = "Top Rope"
                        let defaultGrade = "5.9"

                        self.addClimb.categoryPicker.tap()
                        self.addClimb.pickerOption(forRawValue: rawCategoryValue).tap()
                        XCTAssertTrue(self.addClimb.submitButton.isHittable)
                        self.addClimb.submitButton.tap()

                        XCTAssertTrue(self.climbHistory.view
                                        .waitForExistence(timeout: 2))

                        XCTAssertEqual(self.climbHistory.rows.count, 1)

                        let firstRowText = self.climbHistory.rows.first?.cellText ?? ""
                        XCTAssertTrue(firstRowText.contains(defaultGrade))

                        XCTAssertTrue(firstRowText.contains(rawCategoryValue))
                    }
                }

                describe("When I submit a climb with a custom category and a custom grade") {
                    it("Then I see a new climb with the custom grade and category") {
                        let rawCategoryValue = "Sport"
                        let rawGradeValue = "5.11a"

                        self.addClimb.categoryPicker.tap()
                        self.addClimb.pickerOption(forRawValue: rawCategoryValue).tap()
                        self.addClimb.gradePicker.tap()
                        self.addClimb.pickerOption(forRawValue: rawGradeValue).tap()
                        XCTAssertTrue(self.addClimb.submitButton.isHittable)
                        self.addClimb.submitButton.tap()

                        XCTAssertTrue(self.climbHistory.view
                                        .waitForExistence(timeout: 2))

                        XCTAssertEqual(self.climbHistory.rows.count, 1)

                        let firstRowText = self.climbHistory.rows.first?.cellText ?? ""
                        XCTAssertTrue(firstRowText.contains(rawGradeValue))

                        XCTAssertTrue(firstRowText.contains(rawCategoryValue))
                    }
                }
            }
        }
    }
}
