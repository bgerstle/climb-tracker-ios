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

    let climbAttributes: Climb.Attributes

    var climbedAtString: String {
        climbedAtFormatter.string(from: climbAttributes.climbedAt)
    }

    var body: some View {
        HStack {
            Text("\(climbAttributes.category.displayTitle) \(climbAttributes.grade.description) at \(climbedAtString)")
        }
        .accessibility(identifier: "climbHistoryRow")
        .fixedSize(horizontal: false, vertical: true)
        .padding(Edge.Set(arrayLiteral: .vertical, .leading))
    }
}

struct ClimbHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        ClimbHistoryRow(climbAttributes: Climb.Attributes(climbedAt: Date(),
                                                          grade: BoulderGrade.easy,
                                                          category: BoulderCategory.self))
    }
}
