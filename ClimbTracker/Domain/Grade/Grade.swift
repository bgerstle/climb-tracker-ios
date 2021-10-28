//
//  Grade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/22/21.
//

import Foundation

enum GradingSystem {
    case hueco(HuecoGrade), yosemite(YosemiteDecimalGrade)
}

extension GradingSystem : RawRepresentable {
    init?(rawValue: RawValue) {
        guard let grade = HuecoGrade(rawValue: rawValue).map(\.system) ??
                YosemiteDecimalGrade(rawValue: rawValue).map(\.system) else {
                    return nil
                }
        self = grade
    }

    var rawValue: String {
        switch self {
        case .hueco(let grade):
            return grade.rawValue
        case .yosemite(let grade):
            return grade.rawValue
        }
    }

    typealias RawValue = String
}

// Phantom type for tagging Grades that can be used with boulders
protocol Boulder {}
typealias BoulderGrade = Boulder & Grade

// Phantom type for tagging Grades that can be used with routes
protocol Rope {}
typealias RopeGrade = Rope & Grade

// Concrete grade types should conform to this protocol
protocol Grade
    : RawRepresentable, Hashable, Identifiable, CaseIterable
    where RawValue == String, AllCases: RandomAccessCollection {
    var system: GradingSystem { get }
}
