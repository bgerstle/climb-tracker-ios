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

    let climb: AnyClimb

    var climbedAtString: String {
        climbedAtFormatter.string(from: climb.climbedAt)
    }

    var body: some View {
        HStack {
            Text("\(climb.category.displayTitle) \(climb.grade) at \(climbedAtString)")
        }
        .accessibility(identifier: "climbHistoryRow")
        .fixedSize(horizontal: false, vertical: true)
        .padding(Edge.Set(arrayLiteral: .vertical, .leading))
    }
}

struct ClimbHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        ClimbHistoryRow(climb: Climb<BoulderCategory>(id: UUID(),
                                                      climbedAt: Date(),
                                                      grade: BoulderGrade.easy))
    }
}
