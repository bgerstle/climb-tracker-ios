//
//  XCUIElement+PageObject.swift
//  ClimbTrackerUITests
//
//  Created by Brian Gerstle on 12/10/21.
//

import XCTest

protocol PageObject {
    var view: XCUIElement { get }
}

extension PageObject {
    func textFromLabel(withIdentifier identifier: String) -> String {
        view.staticTexts
            .matching(identifier: identifier)
            .firstMatch
            .label
    }
}
