//
//  AddClimbViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/19/21.
//

import Foundation
import SwiftUI

class AddProjectViewModel: ObservableObject {
    let boulderProjectService: BoulderProjectService!
    let ropeProjectService: RopeProjectService!

    @Published var selectedCategory: ProjectCategory

    @Published var selectedBoulderGrade: HuecoGrade

    @Published var selectedRopeGrade: YosemiteDecimalGrade

    init(boulderProjectService: BoulderProjectService! = nil,
         ropeProjectService: RopeProjectService! = nil,
         selectedCategory: ProjectCategory = .boulder,
         selectedBoulderGrade: HuecoGrade = HuecoGrade.easy,
         selectedRopeGrade: YosemiteDecimalGrade = YosemiteDecimalGrade.nine) {
        self.boulderProjectService = boulderProjectService
        self.ropeProjectService = ropeProjectService
        self.selectedCategory = selectedCategory
        self.selectedRopeGrade = selectedRopeGrade
        self.selectedBoulderGrade = selectedBoulderGrade
    }

    func submit() {
        switch self.selectedCategory {
        case .boulder:
            boulderProjectService.create(grade: selectedBoulderGrade)
        case .rope:
            ropeProjectService.create(grade: selectedRopeGrade)
        }
    }
}
