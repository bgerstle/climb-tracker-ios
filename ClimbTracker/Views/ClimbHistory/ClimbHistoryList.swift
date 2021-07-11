//
//  ClimbHistoryList.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/2/21.
//

import SwiftUI

struct ClimbHistoryList: View {
    @State private var presentingAddClimb: Bool = false

    var body: some View {
        NavigationView {
            List {

            }
            .navigationTitle("Climbs")
            .navigationBarItems(trailing:
                Button("Log Climb") {
                    presentingAddClimb.toggle()
                }
                .accessibility(identifier: "addClimbButton")
            )
            .sheet(isPresented: $presentingAddClimb, content: AddClimbView.init)
        }
        .accessibility(identifier: "climbHistoryList")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ClimbHistoryList()
    }
}
