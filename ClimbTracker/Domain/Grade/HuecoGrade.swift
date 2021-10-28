//
//  BoulderGrade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

enum HuecoGrade : String, BoulderGrade {
    case easy = "VB",
         zero = "V0",
         one = "V1",
         two = "V2",
         three = "V3",
         four = "V4",
         five = "V5",
         six = "V6",
         seven = "V7",
         eight = "V8",
         nine = "V9",
         ten = "V10",
         eleven = "V11",
         twelve = "V12",
         thirteen = "V13",
         fourteen = "V14",
         fifteen = "V15",
         sixteen = "V16"

    var description: String { self.rawValue }

    var id: HuecoGrade { self }

    static func < (lhs: HuecoGrade, rhs: HuecoGrade) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }

    var system: GradingSystem { .hueco(self) }
}
