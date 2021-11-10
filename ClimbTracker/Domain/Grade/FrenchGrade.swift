//
//  FrenchGrade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/10/21.
//

import Foundation

// French != Font
// https://en.wikipedia.org/wiki/Grade_(climbing)#French_numerical_grades
// The grades in this system appear similar to those used in France for free climbing (French numerical system), but have different meaning. For instance, an 8a free-climbing route is significantly easier than an 8A boulder problem. Typically, uppercase letters are used in this system (e.g. 8A), while lowercase letters are preferred in the French numerical system (e.g. 8a
enum FrenchGrade : String, RopeGrade  {
    typealias ID = FrenchGrade

    case one = "1",
         two = "2",
         three = "3",
         four = "4",
         five = "5",
         sixAMinus = "6a-",
         sixA = "6a",
         sixAPlus = "6a+"

    var any: AnyRopeGrade { .french(self) }
}
