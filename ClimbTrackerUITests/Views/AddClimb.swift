//
//  NewClimb.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 7/10/21.
//

import XCTest

class AddClimb {
    public let view: XCUIElement
    public var navigationBar: XCUIElement {
        view.navigationBars.firstMatch
    }

    init(view: XCUIElement) {
        self.view = view
    }

    public var gradePicker: XCUIElement {
        self.view.descendants(matching: .any).matching(identifier: "gradePicker").firstMatch
    }

    public var categoryPicker: XCUIElement {
        self.view.descendants(matching: .any).matching(identifier: "categoryPicker").firstMatch
    }

    public func pickerOption(forRawValue rawValue: String) -> XCUIElement {
        return self.view.descendants(matching: .any).matching(identifier: rawValue).firstMatch
    }

    public var submitButton: XCUIElement {
        navigationBar
            .buttons
            .matching(identifier: "submitButton")
            .firstMatch
    }
}

extension XCUIApplication {
    var addClimb: AddClimb {
        return AddClimb(
            view: descendants(matching: .any)
                .matching(identifier: "addClimbView")
                .firstMatch
        )
    }
}
