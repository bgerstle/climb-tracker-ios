//
//  Utils.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 11/22/21.
//

import XCTest

extension XCUIApplication {
    func resetDatabaseOnLaunch() {
        launchArguments.append("-resetDatabase")
    }
}
