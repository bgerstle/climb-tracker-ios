//
//  Climb.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 10/23/21.
//

import Foundation

protocol AnyClimb {
    var result: ClimbResult { get }
}

enum ClimbResult {
    case flash, onsight, send, fall
}

protocol ClimbType: AnyClimb, Hashable {
    associatedtype GradeType: Grade

    static var projectCategory: ProjectCategory { get }
}

struct BoulderClimb<G: BoulderGrade>: ClimbType  {
    typealias GradeType = G
    
    let result: ClimbResult

    static var projectCategory: ProjectCategory { .boulder }
}

enum RopeClimbCategory {
    case topRope, sport
}

struct RopeClimb<G: RopeGrade>: ClimbType {
    typealias GradeType = G

    let result: ClimbResult
    let ropeCategory: RopeClimbCategory

    static var projectCategory: ProjectCategory { .rope }
}
