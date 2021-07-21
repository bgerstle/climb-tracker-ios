//
//  AddClimbViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/19/21.
//

import Foundation
import SwiftUI

class AddClimbViewModel: ObservableObject {
    let climbService: ClimbService!

    @Published var selectedCategory: Category

    @Published var selectedBoulderGrade: BoulderGrade

    @Published var selectedRopeGrade: RopeGrade

    init(climbService: ClimbService! = nil,
         selectedCategory: Category = .boulder,
         selectedBoulderGrade: BoulderGrade = BoulderGrade.easy,
         selectedRopeGrade: RopeGrade = RopeGrade.nine) {
        self.climbService = climbService
        self.selectedCategory = selectedCategory
        self.selectedRopeGrade = selectedRopeGrade
        self.selectedBoulderGrade = selectedBoulderGrade
    }

    func submit() {
        let climbedAt = Date()

        switch self.selectedCategory {
        case .boulder:
            climbService.create(climb: Climb.Attributes(climbedAt: climbedAt,
                                                        grade: selectedBoulderGrade,
                                                        category: BoulderCategory.self))
        case .topRope:
            climbService.create(climb: Climb.Attributes(climbedAt: climbedAt,
                                                        grade: selectedRopeGrade,
                                                        category: TopRopeCategory.self))
        case .sport:
            climbService.create(climb: Climb.Attributes(climbedAt: climbedAt,
                                                        grade: selectedRopeGrade,
                                                        category: SportCategory.self))
        }
    }
}
