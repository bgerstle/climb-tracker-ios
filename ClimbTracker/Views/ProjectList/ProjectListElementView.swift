//
//  ClimbHistoryRow.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import SwiftUI

struct ProjectListElementView: View {
    let project: ProjectSummary

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(project.grade)
                    .accessibilityIdentifier("projectListElementGrade")
                Text(project.title)
                    .accessibilityIdentifier("projectListElementTitle")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibility(identifier: "projectListElement")
        .padding(Edge.Set(arrayLiteral: .vertical, .leading, .trailing))
    }
}

struct ClimbHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListElementView(project: ProjectSummary(id: UUID(),
                                                       didSend: false,
                                                       attemptCount: 0,
                                                       title: "Example title",
                                                       grade: "V4"))
    }
}
