//
//  PrincipalClass.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/22/21.
//

import Foundation
import XCTest

class PrincipalClass : NSObject {
    override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(TestDatabase.eventStore)
    }
}
