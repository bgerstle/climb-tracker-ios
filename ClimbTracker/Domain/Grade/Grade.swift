//
//  Grade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/22/21.
//

import Foundation

enum AnyBoulderGrade : RawRepresentable, Hashable, Codable {
    case hueco(HuecoGrade)
    case font(FontGrade)

    typealias RawValue = String

    init?(rawValue: RawValue) {
        if let grade = HuecoGrade(rawValue: rawValue) {
            self = .hueco(grade)
        } else if let grade = FontGrade(rawValue: rawValue) {
            self = .font(grade)
        } else {
            return nil
        }
    }

    var rawValue: String {
        switch self {
        case .hueco(let grade):
            return grade.rawValue
        case .font(let grade):
            return grade.rawValue
        }
    }
}

enum AnyRopeGrade : RawRepresentable, Hashable, Codable {
    case yosemite(YosemiteDecimalGrade)
    case french(FrenchGrade)

    typealias RawValue = String

    init?(rawValue: RawValue) {
        if let grade = YosemiteDecimalGrade(rawValue: rawValue) {
            self = .yosemite(grade)
        } else if let grade = FrenchGrade(rawValue: rawValue) {
            self = .french(grade)
        } else {
            return nil
        }
    }

    var rawValue: String {
        switch self {
        case .french(let grade):
            return grade.rawValue
        case .yosemite(let grade):
            return grade.rawValue
        }
    }
}

// Phantom type for tagging Grades that can be used with boulders
protocol Boulder {
    var any: AnyBoulderGrade { get }
}
typealias BoulderGrade = Boulder & Grade

// Phantom type for tagging Grades that can be used with routes
protocol Rope {
    var any: AnyRopeGrade { get }
}
typealias RopeGrade = Rope & Grade

// Concrete grade types should conform to this protocol
protocol Grade
    : RawRepresentable, Hashable, Identifiable, CaseIterable
    where RawValue == String, AllCases: RandomAccessCollection {
}

extension Grade where ID == Self {
    var id: Self { self }
}
