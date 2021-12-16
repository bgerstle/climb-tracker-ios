//
//  BoulderProjectTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/23/21.
//

import Foundation
import XCTest
@testable import ClimbTracker

class BoulderProjectTests : XCTestCase {
    func testAttemptedPayload() {
        let payload = BoulderProject.Event.Attempted(projectId: UUID(), attemptId: UUID(), didSend: false, attemptedAt: Date())
        let attemptedEvent = BoulderProject.Event.attempted(payload)
        let encodedEvent = try! attemptedEvent.payload()
        let decodedEvent = try! BoulderProject.Event(payloadType: .attempted, payload: encodedEvent)
        XCTAssertEqual(decodedEvent, attemptedEvent)
    }
}
