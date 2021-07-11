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

    init(climbService: ClimbService! = nil) {
        self.climbService = climbService
    }

    var body: some View {
        NavigationView {
            VStack {

            }
            .navigationTitle("Add Climb")
            .navigationBarItems(trailing:
                Button("Submit") {
                    presentationMode.wrappedValue.dismiss()
                    climbService.create(
                        climb: ClimbAttributes(
                            climbedAt: Date(),
                            kind: .boulder(grade: .easy)
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
