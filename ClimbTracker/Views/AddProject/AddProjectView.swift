//
//  NewClimbView.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/10/21.
//

import SwiftUI
import Combine

enum ProjectCategory: String, Hashable, CaseIterable {
    case boulder = "boulder",
         rope = "rope"
}

struct AddProjectView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: AddProjectViewModel

    var body: some View {
        NavigationView {
            Form {
                Section("Project Name") {
                    TextField(
                        "",
                        text: $viewModel.projectName
                    )
                }

                Section("Grade") {
                    CategoryPicker(selectedCategory: $viewModel.selectedCategory)

                    switch viewModel.selectedCategory {
                    case .boulder:
                        GradePicker<HuecoGrade>(selectedGrade: $viewModel.selectedBoulderGrade)
                    case .rope:
                        GradePicker<YosemiteDecimalGrade>(selectedGrade: $viewModel.selectedRopeGrade)
                    }
                }
            }
            .navigationTitle("New Project")
            .navigationBarItems(trailing:
                Button("Create") {
                    presentationMode.wrappedValue.dismiss()
                    viewModel.submit()
                }
                .accessibility(identifier: "submitButton")
            )
        }
        .accessibility(identifier: "addProjectView")
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView(viewModel: AddProjectViewModel(projectService: nil))
    }
}
