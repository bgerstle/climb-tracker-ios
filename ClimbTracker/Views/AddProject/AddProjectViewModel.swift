//
//  AddProjectViewModel.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/19/21.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AddProjectViewModel: ObservableObject {
    let projectService: ProjectService
    let projectNameService: ProjectNameService

    @Published var selectedCategory: ProjectCategory

    @Published var selectedBoulderGrade: HuecoGrade

    @Published var selectedRopeGrade: YosemiteDecimalGrade

    @Published var projectName: String = ""

    @Published var projectNameValid: Bool = true

    var validateProjectNameSubscription: AnyCancellable? = nil

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

        validateProjectName()
    }

    private func validateProjectName() {
        self.validateProjectNameSubscription =  $projectName.sink { name in
            Task {
                do {
                    self.projectNameValid = try await self.projectNameService.getProject(forName: name) == nil
                } catch {
                }
            }
        }
    }

    var optionalProjectName: String? {
        projectName.isEmpty ? nil : projectName
    }

    func submit() {
        Task {
            do {
                switch self.selectedCategory {
                case .boulder:
                    try await projectNameService.createProject(
                        grade: selectedBoulderGrade,
                        name: optionalProjectName,
                        withFactory: projectService.create
                    )
                case .rope:
                    try await projectNameService.createProject(
                        grade: selectedRopeGrade,
                        name: optionalProjectName,
                        withFactory: projectService.create
                    )
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
