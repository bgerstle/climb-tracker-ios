//
//  AddClimbViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/19/21.
//

import Foundation
import SwiftUI

class AddProjectViewModel: ObservableObject {
    let climbService: ProjectService!

    @Published var selectedCategory: ProjectCategory

    @Published var selectedBoulderGrade: HuecoGrade

    @Published var selectedRopeGrade: YosemiteDecimalGrade

    init(climbService: ProjectService! = nil,
         selectedCategory: ProjectCategory = .boulder,
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
        case .route:
            climbService.create(climbedAt: climbedAt,
                                grade: selectedRopeGrade,
                                category: TopRopeCategory.self)
        }
    }
}
