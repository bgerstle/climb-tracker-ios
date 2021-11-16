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
import SwiftUI

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

                    let publishedEventEnvelopes = try self.wait(for: self.recorder.availableElements, timeout: 1.0)
                    XCTAssertEqual(publishedEventEnvelopes.count, 1)
                    guard case .named(let event) = publishedEventEnvelopes.first?.event else {
                        XCTFail("expected named event but got \(publishedEventEnvelopes)")
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
                        return try await self.service.getProject(forName: uniqueName)
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

            context("When renaming a project") {
                it("Then it publishes another named event") {
                    let projectId = UUID(),
                        uniqueName1 = "foo",
                        uniqueName2 = "bar"

                    try self.expectAsync {
                        try await self.service.name(projectId: projectId, uniqueName1)
                        try await self.service.name(projectId: projectId, uniqueName2)
                    }

                    let publishedEventEnvelopes = try self.wait(for: self.recorder.availableElements, timeout: 1.0)
                    XCTAssertEqual(publishedEventEnvelopes.count, 2)

                    let publishedNamedEventPayloads: [ProjectNameEvent.Named] = publishedEventEnvelopes.compactMap { envelope in
                        guard case .named(let event) = envelope.event else {
                            XCTFail("expected named event but got \(publishedEventEnvelopes)")
                            return nil
                        }
                        return event
                    }

                    XCTAssertEqual(publishedNamedEventPayloads.map(\.projectId), [projectId, projectId])
                    XCTAssertEqual(publishedNamedEventPayloads.map(\.name), [uniqueName1, uniqueName2])
                }

                it("And it only associates the new name with the project") {
                    let projectId = UUID(),
                        uniqueName1 = "foo",
                        uniqueName2 = "bar"

                    let result: (nameForProject: String?, projectForName1: ProjectID?, projectForName2: ProjectID?) =
                        try self.expectAsync {
                        try await self.service.name(projectId: projectId, uniqueName1)
                        try await self.service.name(projectId: projectId, uniqueName2)

                        async let nameForProject = self.service.getName(forProject: projectId)
                        async let projectForName1 = self.service.getProject(forName: uniqueName1)
                        async let projectForName2 = self.service.getProject(forName: uniqueName2)

                        return try await (nameForProject: nameForProject,
                                          projectForName1: projectForName1,
                                          projectForName2: projectForName2)
                    }

                    XCTAssertEqual(result.nameForProject, uniqueName2)
                    XCTAssertNil(result.projectForName1)
                    XCTAssertEqual(result.projectForName2, projectId)
                }
            }

            it("Maintains name uniqueness despite concurrent naming attempts") {
                // given N names
                let countNames = 10,
                    names: [String] = (0..<countNames).map { "name-\($0)" },
                    // When M projects try to claim them concurrently
                    attemptsPerName = 3,
                    attempts = names.flatMap { id in Array(repeating: id, count: attemptsPerName) }.shuffled()

                try self.expectAsync(timeout: 10) {
                    await withThrowingTaskGroup(of: Void.self) { group in
                        attempts.forEach { name in
                            group.addTask {
                                do {
                                    try await self.service.name(projectId: UUID(), name)
                                } catch is NameAlreadyTaken {
                                    // suppress valid exceptions thrown by the name already being taken in subsequent attempts
                                }
                            }
                        }
                    }
                }

                let nameEventEnvelopes: [EventEnvelope<ProjectNameEvent>] =
                    try self.wait(for: self.recorder.availableElements, timeout: 2.0)

                let duplicateProjectIdsByName: [String: [ProjectID]] = nameEventEnvelopes.compactMap { envelope in
                        switch envelope.event {
                        case .named(let event):
                            return event
                        }
                    }
                    .reduce(into: [String:[ProjectID]]()) { (projectIdsByName: inout [String:[ProjectID]], event: ProjectNameEvent.Named) in
                        var projects = projectIdsByName[event.name, default: []]
                        projects.append(event.projectId)
                        projectIdsByName[event.name] = projects
                    }
                    .filter { $0.value.count > 1 }

                // Then there should be no duplicates
                XCTAssertEqual(duplicateProjectIdsByName, [String:[ProjectID]]())
            }
        }
    }
}
