//
//  Grade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/22/21.
//

import Foundation

// Erased/polymorphic type that can refer to any grade
protocol AnyGrade: CustomStringConvertible { }

// Concrete grade types should conform to this protocol
protocol Grade: AnyGrade, Hashable, Identifiable, CaseIterable, RawRepresentable
where RawValue == String, AllCases: RandomAccessCollection {
}

// Type used to enforce which grades & categories can be used together (see Climb.Attributes)
protocol CategoryType {
    associatedtype GradeType: Grade

    static var id: ProjectCategory { get }
}
