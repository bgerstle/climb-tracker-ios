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
    var climbService: ClimbService!

    @State var selectedGrade: BoulderGrade = BoulderGrade.easy

    init(climbService: ClimbService! = nil) {
        self.climbService = climbService
    }

    var body: some View {
        NavigationView {
            Form {
                Section() {
                    HStack {
                        Picker(selection: $selectedGrade, label: Text("Grade")) {
                            ForEach(BoulderGrade.allCases) { grade in
                                Text(grade.description)
                                    .tag(grade)
                                    .accessibility(identifier: grade.rawValue)
                            }
                        }
                        .accessibility(identifier: "gradePicker")
                    }
                }
            }
            .navigationTitle("Add Climb")
            .navigationBarItems(trailing:
                Button("Submit") {
                    presentationMode.wrappedValue.dismiss()
                    climbService.create(
                        climb: ClimbAttributes(
                            climbedAt: Date(),
                            kind: .boulder(grade: selectedGrade)
                        )
                    )
                }
                .accessibility(identifier: "submitButton")
            )
        }
        .accessibility(identifier: "addClimbView")
    }
}

struct NewClimbView_Previews: PreviewProvider {
    static var previews: some View {
        AddClimbView()
    }
}
