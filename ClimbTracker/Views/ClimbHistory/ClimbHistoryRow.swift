//
//  ClimbHistoryRow.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/10/21.
//

import SwiftUI

struct ClimbHistoryRow: View {
    var climb: Any!

    var body: some View {
        HStack {
            Text("some climb")
            Spacer()
        }.accessibility(identifier: "climbHistoryRow")
    }
}

struct ClimbHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        ClimbHistoryRow()
    }
}
