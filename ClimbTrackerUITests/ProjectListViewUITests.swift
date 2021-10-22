//
//  ClimbTrackerUITests.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/2/21.
//

import XCTest
import Quick

class ProjectListViewUITests: QuickSpec {
    var app: XCUIApplication!

    var climbHistory: ProjectListPageObject {
        app.climbHistory
    }

    override func spec() {
        beforeEach {
            self.continueAfterFailure = false
            self.app = XCUIApplication()
            self.app.launch()
        }

        describe("Projects") {
            context("When there are no projects") {
                it("Then the view is empty") {
                    XCTAssertTrue(self.climbHistory.view.isHittable)
                    XCTAssertEqual(self.climbHistory.rows.count, 0)
                }

                it("And there should be a 'New Project' button") {
                    XCTAssertTrue(self.climbHistory.newProjectButton.isHittable)
                }
            }

            context("When I tap the 'New Project' button") {
                beforeEach {
                    self.climbHistory.newProjectButton.tap()
                }

                it("Then I should see the Add Project view") {
                    XCTAssertTrue(self.app.addClimb.view.exists)
                }
            }
        }
    }
}
