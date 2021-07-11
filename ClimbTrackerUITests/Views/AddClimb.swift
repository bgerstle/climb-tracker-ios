//
//  NewClimb.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/10/21.
//

import XCTest

class AddClimb {
    public let view: XCUIElement

    init(view: XCUIElement) {
        self.view = view
    }
}

extension XCUIApplication {
    var addClimb: AddClimb {
        return AddClimb(view: descendants(matching: .any)
                            .matching(identifier: "addClimbView")
                            .firstMatch)
    }
}
