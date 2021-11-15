//
//  ProjectNameEventServiceTests.swift
//  ClimbTrackerTests
//
//  Created by Brian Gerstle on 11/15/21.
//

import Foundation
import Quick
import CombineExpectations
@testable import ClimbTracker
import XCTest

class ProjectNameEventServiceTests : QuickSpec {
    var eventStore: EventStore!
    var service: ProjectNameEventService!
    var recorder: Recorder<EventEnvelope<ProjectNameEvent>, Error>!

    override func spec() {
        describe("Naming projects") {
            beforeEach {
                self.eventStore = EphemeralEventStore()
                self.service = ProjectNameEventService(eventStore: self.eventStore)
                self.recorder = self.eventStore.namespaceEvents().record()
            }

            context("When assigning a project with a unique name") {
                it("Then it writes a ProjectNamed event") {
                    let projectId = UUID(),
                        uniqueName = "foo"

                    try self.expectAsync {
                        try await self.service.name(projectId: projectId, uniqueName)
                    }

                    let publishedEventEnvelope = try self.wait(for: self.recorder.next(), timeout: 1.0)
                    guard case .named(let event) = publishedEventEnvelope.event else {
                        XCTFail("expected named event but got \(publishedEventEnvelope)")
                        return
                    }
                    XCTAssertEqual(event.projectId, projectId)
                    XCTAssertEqual(event.name, uniqueName)
                }

                it("And the name can be retrieved by findName") {
                    let projectId = UUID(),
                        uniqueName = "foo"

                    let foundProjectId: ProjectID? = try self.expectAsync {
                        try await self.service.name(projectId: projectId, uniqueName)
                        return try await self.service.find(name: uniqueName)
                    }

                    XCTAssertEqual(projectId, foundProjectId)
                }
            }

            it("When naming a project with a duplicate name, then it fails") {
                let projectId1 = UUID(),
                    projectId2 = UUID(),
                    uniqueName = "foo"

                try self.expectAsync {
                    try await self.service.name(projectId: projectId1, uniqueName)
                }

                let nameProject2Result = Result {
                    try self.expectAsync {
                        try await self.service.name(projectId: projectId2, uniqueName)
                    }
                }

                guard case .failure(let error) = nameProject2Result else {
                    XCTFail("expected failed result but got \(nameProject2Result)")
                    return
                }
                XCTAssertTrue(error is NameAlreadyTaken)
            }
        }
    }
}
