//
//  GradePicker.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/19/21.
//

import SwiftUI

struct GradePicker<G: Grade>: View {
    @Binding var selectedGrade: G

    var body: some View {
        Picker(selection: $selectedGrade, label: Text("Grade")) {
            List(G.allCases) { grade in
                Text(grade.description)
                    .tag(grade)
                    .accessibility(identifier: grade.rawValue)
            }
        }
        .pickerStyle(.inline)
        .accessibility(identifier: "gradePicker")
    }
}

struct GradePicker_Previews: PreviewProvider {
    static var previews: some View {
        GradePicker<HuecoGrade>(selectedGrade: .constant(HuecoGrade.easy))
    }
}
