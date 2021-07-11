//
//  ClimbHistoryList.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/2/21.
//

import SwiftUI

struct ClimbHistoryList: View {
    var body: some View {
        NavigationView {
            List {

            }
            .accessibility(identifier: "climbHistoryList")
            .navigationTitle("Climbs")
            .navigationBarItems(trailing: Button("Log Climb") {
                print("log climb tapped")
            }.accessibility(identifier: "logClimbButton"))

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ClimbHistoryList()
    }
}
