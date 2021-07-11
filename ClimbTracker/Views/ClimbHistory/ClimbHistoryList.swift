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
            .accessibility(identifier: "climbHistoryList")
            .navigationTitle("Climbs")
            .navigationBarItems(trailing:
                Button("Log Climb") {
                    presentingAddClimb.toggle()
                }
                .sheet(isPresented: $presentingAddClimb, content: AddClimbView.init)
                .accessibility(identifier: "addClimbButton")
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ClimbHistoryList()
    }
}
