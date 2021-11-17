//
//  AddProjectViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/19/21.
//

import Foundation
import SwiftUI

@MainActor
class AddProjectViewModel: ObservableObject {
    let projectService: ProjectService
    let projectNameService: ProjectNameService

    @Published var selectedCategory: ProjectCategory

    @Published var selectedBoulderGrade: HuecoGrade

    @Published var selectedRopeGrade: YosemiteDecimalGrade

    @Published var projectName: String = ""

    init(projectService: ProjectService,
         projectNameService: ProjectNameService,
         selectedCategory: ProjectCategory = .boulder,
         selectedBoulderGrade: HuecoGrade = HuecoGrade.easy,
         selectedRopeGrade: YosemiteDecimalGrade = YosemiteDecimalGrade.nine) {
        self.projectService = projectService
        self.projectNameService = projectNameService
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
                    try await projectService.create(grade: selectedBoulderGrade)
                case .rope:
                    try await projectService.create(grade: selectedRopeGrade)
                }
            } catch {
                print("TODO: put this in the UI! \(error)")
            }
        }
    }
}

extension PreviewProvider {
    static var previewAddProjectViewModel: AddProjectViewModel {
        AddProjectViewModel(
            projectService: previewProjectService,
            projectNameService: previewProjectNameService
        )
    }
}
