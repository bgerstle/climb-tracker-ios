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
        switch self.selectedCategory {
        case .boulder:
            climbService.create(BoulderClimb.self, grade: selectedBoulderGrade)
        case .rope:
            climbService.create(RopeClimb.self, grade: selectedRopeGrade)
        }
    }
}
