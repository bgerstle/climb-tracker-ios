//
//  RopeGrade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/19/21.
//

import Foundation

enum YosemiteDecimalGrade: String, RopeGrade {
    typealias ID = YosemiteDecimalGrade

    case zero = "5.0",
         one = "5.1",
         two = "5.2",
         three = "5.3",
         four = "5.4",
         five = "5.5",
         six = "5.6",
         seven = "5.7",
         eight = "5.8",
         nine = "5.9",
         tenA = "5.10a",
         tenB = "5.10b",
         tenC = "5.10c",
         tenD = "5.10d",
         elevenA = "5.11a",
         elevenB = "5.11b",
         elevenC = "5.11c",
         elevenD = "5.11d",
         twelveA = "5.12a",
         twelveB = "5.12b",
         twelveC = "5.12c",
         twelveD = "5.12d",
         thirteenA = "5.13a",
         thirteenB = "5.13b",
         thirteenC = "5.13c",
         thirteenD = "5.13d"

    var description: String {
        self.rawValue
    }

    static func < (lhs: YosemiteDecimalGrade, rhs: YosemiteDecimalGrade) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }

    var any: AnyRopeGrade { .yosemite(self) }
}
