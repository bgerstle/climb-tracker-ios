//
//  Attempt.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 10/23/21.
//

import Foundation

protocol AnyAttempt {
    var didSend: Bool { get }
}

protocol AttemptType: AnyAttempt, Hashable {
    associatedtype GradeType: Grade

    static var projectCategory: ProjectCategory { get }
}

struct BoulderAttempt<G: BoulderGrade>: AttemptType  {
    typealias GradeType = G
    
    let didSend: Bool

    static var projectCategory: ProjectCategory { .boulder }
}

enum RopeSubcategory {
    case topRope, sport
}

struct RopeAttempt<G: RopeGrade>: AttemptType {
    typealias GradeType = G

    let didSend: Bool
    let ropeSubcategory: RopeSubcategory

    static var projectCategory: ProjectCategory { .rope }
}
