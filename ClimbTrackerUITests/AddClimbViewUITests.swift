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

                context("When I log a bouldering send") {
                    beforeEach {
                        self.addClimb.submitButton.tap()
                    }

                    it("Then I am taken back to my climb history") {
                        XCTAssertTrue(self.climbHistory.view
                                        .waitForExistence(timeout: 2))
                    }

                    it("And it shows the climb I added") {
                        XCTAssertEqual(self.climbHistory.rows.count, 1)
                    }
                }

                describe("When I swipe down") {
                    beforeEach {
                        self.app.swipeDown()
                    }

                    it("Then I am taken back to climb history") {
                        XCTAssertFalse(self.addClimb.view.isHittable)
                        XCTAssertTrue(self.app.climbHistory.view.isHittable)
                    }
                }
            }
        }
    }
}
