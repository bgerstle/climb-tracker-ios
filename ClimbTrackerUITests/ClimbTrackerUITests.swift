//
//  ClimbTrackerUITests.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/2/21.
//

import XCTest
import Quick

class ClimbTrackerUITests: QuickSpec {
    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
        }

        describe("Climb history") {
            context("When this is no history") {
                it("Then the view is empty") {
                    // UI tests must launch the application that they test.
                    let app = XCUIApplication()
                    app.launch()

                    let climbHistory = app.climbHistory
                    XCTAssertTrue(climbHistory.view.isHittable)
                    XCTAssertTrue(climbHistory.rows.count == 0)
                }
            }
        }
    }
}
