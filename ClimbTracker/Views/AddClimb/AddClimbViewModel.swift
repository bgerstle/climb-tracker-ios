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

    @Published var selectedBoulderGrade: HuecoGrade

    @Published var selectedRopeGrade: YosemiteDecimalGrade

    init(climbService: ClimbService! = nil,
         selectedCategory: Category = .boulder,
         selectedBoulderGrade: HuecoGrade = HuecoGrade.easy,
         selectedRopeGrade: YosemiteDecimalGrade = YosemiteDecimalGrade.nine) {
        self.climbService = climbService
        self.selectedCategory = selectedCategory
        self.selectedRopeGrade = selectedRopeGrade
        self.selectedBoulderGrade = selectedBoulderGrade
    }

    func submit() {
        let climbedAt = Date()

        switch self.selectedCategory {
        case .boulder:
            climbService.create(climbedAt: climbedAt,
                                grade: selectedBoulderGrade,
                                category: BoulderCategory.self)
        case .topRope:
            climbService.create(climbedAt: climbedAt,
                                grade: selectedRopeGrade,
                                category: TopRopeCategory.self)
        case .sport:
            climbService.create(climbedAt: climbedAt,
                                grade: selectedRopeGrade,
                                category: SportCategory.self)
        }
    }
}
