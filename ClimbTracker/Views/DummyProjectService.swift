//
//  DummyProjectService.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/11/21.
//

import Foundation
import SwiftUI

// Dummy services that can only be used in previews
class DummyProjectService : RopeProjectService, BoulderProjectService {
    func create<G: BoulderGrade>(grade: G) {}

    func create<G: RopeGrade>(grade: G) {}

    func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory) {}

    func attempt(projectId: UUID, at: Date, didSend: Bool) {}

    init<P: PreviewProvider>(_ _: P.Type) { }
}

extension PreviewProvider {
    static var dummyProjectService: DummyProjectService { DummyProjectService(Self.self) }
}
