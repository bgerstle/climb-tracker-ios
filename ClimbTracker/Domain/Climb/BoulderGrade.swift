//
//  BoulderGrade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

enum BoulderGrade : String, Grade {
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

    var id: BoulderGrade { self }

    static func < (lhs: BoulderGrade, rhs: BoulderGrade) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}
