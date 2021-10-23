//
//  Grade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/22/21.
//

import Foundation

enum GradeType {
    case hueco, yosemite
}

// Concrete grade types should conform to this protocol
protocol Grade
    : RawRepresentable, Hashable, Identifiable, CaseIterable
    where RawValue == String, AllCases: RandomAccessCollection {
    static var typeID: GradeType { get }
}

// Phantom type for tagging Grades that can be used with boulders
protocol BoulderGrade {}

// Phantom type for tagging Grades that can be used with routes
protocol RopeGrade {}
