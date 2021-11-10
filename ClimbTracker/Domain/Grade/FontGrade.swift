//
//  FontGrade.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 11/10/21.
//

import Foundation

enum FontGrade : String, BoulderGrade  {
    typealias ID = FontGrade

    case one = "1",
         two = "2",
         three = "3",
         four = "4",
         five = "5",
         sixAMinus = "6A-",
         sixA = "6A",
         sixAPlus = "6A+"

    var any: AnyBoulderGrade { .font(self) }
}
