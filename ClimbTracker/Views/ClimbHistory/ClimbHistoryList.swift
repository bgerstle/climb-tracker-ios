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
            .navigationTitle("Climbs")
        }
        .accessibility(identifier: "climbHistoryList")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ClimbHistoryList()
    }
}
