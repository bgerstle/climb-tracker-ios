//
//  AddClimbViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/19/21.
//

import Foundation
import SwiftUI

@MainActor
class AddProjectViewModel: ObservableObject {
    let projectService: ProjectService!

    @Published var selectedCategory: ProjectCategory

    @Published var selectedBoulderGrade: HuecoGrade

    @Published var selectedRopeGrade: YosemiteDecimalGrade

    @Published var projectName: String = ""

    init(projectService: ProjectService! = nil,
         selectedCategory: ProjectCategory = .boulder,
         selectedBoulderGrade: HuecoGrade = HuecoGrade.easy,
         selectedRopeGrade: YosemiteDecimalGrade = YosemiteDecimalGrade.nine) {
        self.projectService = projectService
        self.selectedCategory = selectedCategory
        self.selectedRopeGrade = selectedRopeGrade
        self.selectedBoulderGrade = selectedBoulderGrade
    }

    var optionalProjectName: String? {
        projectName.isEmpty ? nil : projectName
    }

    func submit() {
        Task {
            do {
                switch self.selectedCategory {
                case .boulder:
                    try await projectService.create(grade: selectedBoulderGrade, name: optionalProjectName)
                case .rope:
                    try await projectService.create(grade: selectedRopeGrade, name: optionalProjectName)
                }
            } catch {
                print("TODO: put this in the UI! \(error)")
            }
        }
    }
}
