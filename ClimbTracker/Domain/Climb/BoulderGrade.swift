//
//  BoulderGrade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import Foundation

enum BoulderGrade : String, CustomStringConvertible {
    case easy = "B",
         zero = "0",
         one = "1",
         two = "2",
         three = "3",
         four = "4",
         five = "5",
         six = "6",
         seven = "7",
         eight = "8",
         nine = "9",
         ten = "10",
         eleven = "11",
         twelve = "12",
         thirteen = "13",
         fourteen = "14",
         fifteen = "15",
         sixteen = "16"

    var description: String {
        "V\(rawValue)"
    }
}
