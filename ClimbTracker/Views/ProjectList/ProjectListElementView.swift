//
//  ClimbHistoryRow.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import SwiftUI

struct ProjectListElementView: View {
    var projectCreatedAtFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    let project: AnyProject

    var formattedCreationTime: String {
        projectCreatedAtFormatter.string(from: project.createdAt)
    }

    var body: some View {
        HStack {
            Text("\(project.category.displayTitle) \(project.grade) at \(formattedCreationTime)")
        }
        .accessibility(identifier: "climbHistoryRow")
        .fixedSize(horizontal: false, vertical: true)
        .padding(Edge.Set(arrayLiteral: .vertical, .leading))
    }
}

struct ClimbHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListElementView(project: Project<BoulderCategory>(id: UUID(),
                                                      climbedAt: Date(),
                                                      grade: HuecoGrade.easy))
    }
}
