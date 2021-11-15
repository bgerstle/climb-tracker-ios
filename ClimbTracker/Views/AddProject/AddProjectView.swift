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

    @ObservedObject var addClimbViewModel: AddProjectViewModel

    var body: some View {
        NavigationView {
            Form {
                CategoryPicker(selectedCategory: $addClimbViewModel.selectedCategory)

                switch addClimbViewModel.selectedCategory {
                case .boulder:
                    GradePicker<HuecoGrade>(selectedGrade: $addClimbViewModel.selectedBoulderGrade)
                case .rope:
                    GradePicker<YosemiteDecimalGrade>(selectedGrade: $addClimbViewModel.selectedRopeGrade)
                }
            }
            .navigationTitle("New Project")
            .navigationBarItems(trailing:
                Button("Create") {
                    presentationMode.wrappedValue.dismiss()
                    addClimbViewModel.submit()
                }
                .accessibility(identifier: "submitButton")
            )
        }
        .accessibility(identifier: "addProjectView")
    }
}

struct NewClimbView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView(addClimbViewModel: AddProjectViewModel(projectService: nil))
    }
}
