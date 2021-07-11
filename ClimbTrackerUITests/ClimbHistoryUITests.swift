//
//  ClimbTrackerUITests.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/2/21.
//

import XCTest
import Quick

class ClimbTrackerUITests: QuickSpec {
    var app: XCUIApplication!

    var climbHistory: ClimbHistory {
        app.climbHistory
    }

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.app = XCUIApplication()
            self.app.launch()
        }

        describe("Climb history") {
            context("When this is no history") {
                it("Then the view is empty") {
                    XCTAssertTrue(self.climbHistory.view.isHittable)
                    XCTAssertEqual(self.climbHistory.rows.count, 0)
                }

                it("And there should be a log climb button") {
                    XCTAssertTrue(self.climbHistory.addClimbButton.isHittable)
                }
            }

            context("When I tap the add climb button") {
                beforeEach {
                    self.climbHistory.addClimbButton.tap()
                }

                it("Then I should see the add climb view") {
                    XCTAssertTrue(self.app.addClimb.view.exists)
                }
            }
        }
    }
}
