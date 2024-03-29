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

    @State var isProjectNameValid: Bool = true

    var body: some View {
        NavigationView {
            Form {
                Section("Project Name") {
                    VStack(alignment: .leading) {
                        TextField(
                            "",
                            text: $viewModel.projectName
                        )
                            .foregroundColor(isProjectNameValid ? .primary : .red)

                        if !isProjectNameValid {
                            Text("Must be unique")
                                .dynamicTypeSize(.small)
                                .foregroundColor(.red)
                        }
                    }
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
                .disabled(!isProjectNameValid)
                .accessibility(identifier: "submitButton")
            )
            .onReceive(viewModel.$projectNameValid) { isValid in
                isProjectNameValid = isValid
            }
        }
        .accessibility(identifier: "addProjectView")
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = previewAddProjectViewModel
        viewModel.projectName = "Some name"
        return AddProjectView(viewModel: viewModel)
            .preferredColorScheme(.dark)
    }
}
