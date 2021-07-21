//
//  NewClimbView.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/10/21.
//

import SwiftUI
import Combine

struct AddClimbView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var addClimbViewModel: AddClimbViewModel

    var body: some View {
        NavigationView {
            Form {
                CategoryPicker(selectedCategory: $addClimbViewModel.selectedCategory)

                switch addClimbViewModel.selectedCategory {
                case .boulder:
                    GradePicker<BoulderGrade>(selectedGrade: $addClimbViewModel.selectedBoulderGrade)
                case .topRope:
                    GradePicker<RopeGrade>(selectedGrade: $addClimbViewModel.selectedRopeGrade)
                case .sport:
                    GradePicker<RopeGrade>(selectedGrade: $addClimbViewModel.selectedRopeGrade)
                }
            }
            .navigationTitle("Add Climb")
            .navigationBarItems(trailing:
                Button("Submit") {
                    presentationMode.wrappedValue.dismiss()
                    addClimbViewModel.submit()
                }
                .accessibility(identifier: "submitButton")
            )
        }
        .accessibility(identifier: "addClimbView")
    }
}

struct NewClimbView_Previews: PreviewProvider {
    static var previews: some View {
        AddClimbView(addClimbViewModel: AddClimbViewModel(climbService: nil))
    }
}
