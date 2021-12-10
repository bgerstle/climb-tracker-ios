//
//  AddProjectAttemptViewUITests.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 10/28/21.
//

import Quick
import XCTest

class AddProjectAttemptViewUITests: QuickSpec {
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
            self.app.resetDatabaseOnLaunch()
            self.app.launch()
        }

        context("When a boulder project is in the list") {
            beforeEach {
                XCTAssertTrue(self.projectList.view.isHittable)
                self.projectList.newProjectButton.tap()
                let rawGradeValue = "V5"
                let rawCategoryValue = "Boulder"

                // TODO: dry w/ protocol extensions
                self.addProject.categoryPicker.tap()
                self.addProject.pickerOption(forRawValue: rawCategoryValue).tap()

                self.addProject.gradePicker.tap()
                self.addProject.pickerOption(forRawValue: rawGradeValue).tap()
                XCTAssertTrue(self.app.addProject.submitButton.isHittable)
                self.app.addProject.submitButton.tap()
            }

            it("Then I can swipe to see buttons for logging an attempt or send") {
                let firstRow = self.projectList.rows.first!
                firstRow.view.swipeLeft()

                XCTAssertTrue(self.projectList.addAttemptSwipeAction.isHittable)
                XCTAssertTrue(self.projectList.addSendSwipeAction.isHittable)
            }

            it("Then I can log an attempt using the swipe actions") {
                let firstRow = self.projectList.rows.first!
                firstRow.view.swipeLeft()

                self.projectList.addAttemptSwipeAction.tap()

                let attemptStatus = firstRow.attemptStatusLabelText
                XCTAssertTrue(attemptStatus.contains("1 attempt"), "unexpected attempt status \(attemptStatus)")

                let sendStatus = firstRow.sendStatusLabelText
                XCTAssertTrue(sendStatus.contains("projecting"), "unexpected send status: \(sendStatus)")
            }

            it("Then I can log a send using the swipe actions") {
                let firstRow = self.projectList.rows.first!
                firstRow.view.swipeLeft()

                self.projectList.addSendSwipeAction.tap()

                let attemptStatus = firstRow.attemptStatusLabelText
                XCTAssertTrue(attemptStatus.contains("1 attempt"), "unexpected attempt status \(attemptStatus)")

                let sendStatus = firstRow.sendStatusLabelText
                XCTAssertTrue(sendStatus.contains("Sended"), "unexpected send status: \(sendStatus)")
            }
        }
    }
}
