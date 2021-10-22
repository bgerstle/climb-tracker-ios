//
//  Category.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/22/21.
//

import Foundation

enum Category: String, Hashable, Equatable, CaseIterable, Identifiable {
    case boulder = "boulder",
         topRope = "topRope",
         sport = "sport"

    var displayTitle: String {
        switch self {
        case .boulder:
            return "Boulder"
        case .sport:
            return "Sport"
        case .topRope:
            return "Top Rope"
        }
    }

    var id: Category { self }
}
