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
        $projectName.flatMap { [weak self] (name) -> AnyPublisher<Bool, Never> in
            guard let self = self else { return Just(true).eraseToAnyPublisher() }

            // Allow name field to be empty, which will later be interpreted as not having a name
            if name.isEmpty {
                return Just(true).eraseToAnyPublisher()
            }

            return Future { promise in
                Task {
                    let isValid = await self.projectNameService.isValid(name: name)
                    promise(.success(isValid))
                }
            }.eraseToAnyPublisher()
        }.assign(to: &$projectNameValid)
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
