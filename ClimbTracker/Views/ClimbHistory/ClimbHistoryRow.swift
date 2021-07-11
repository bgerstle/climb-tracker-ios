//
//  ClimbHistoryRow.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import SwiftUI

struct ClimbHistoryRow: View {
    var climbedAtFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    let climbAttributes: ClimbAttributes

    var climbedAtString: String {
        climbedAtFormatter.string(from: climbAttributes.climbedAt)
    }

    var body: some View {
        Text("Climbed a \(climbAttributes.kind.description) at \(climbedAtString)")
            .accessibility(identifier: "climbHistoryRow")
    }
}

struct ClimbHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        ClimbHistoryRow(climbAttributes: ClimbAttributes(climbedAt: Date(), kind: .boulder(grade: .easy)))
    }
}
