//
//  ProjectService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation
import Combine

protocol ProjectService {
    // MARK: Boulder Projects
    @discardableResult
    func create<G: BoulderGrade>(grade: G) async throws -> ProjectID

    @discardableResult
    func attempt(projectId: UUID, at: Date, didSend: Bool) async throws -> AttemptID

    // MARK: Rope Projects
    @discardableResult
    func create<G: RopeGrade>(grade: G) async throws -> ProjectID

    // Can types statically enforce that this API can only be invoked for rope projects?
    // (same for boulder attempts?) (and without using typical OOP/ORM patterns?)
    @discardableResult
    func attempt(projectId: UUID,
                 at: Date,
                 didSend: Bool,
                 subcategory: RopeProject.Subcategory) async throws -> AttemptID

    func subscribeToProject<T: EventSourcedProject>(withType projectType: T.Type, id projectId: ProjectID) -> TopicEventPublisher<T.Event>
}
