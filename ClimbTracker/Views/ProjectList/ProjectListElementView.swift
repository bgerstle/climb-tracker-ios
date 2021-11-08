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
        HStack {
            Text(project.title)
            Spacer()
            Text(project.grade)
        }
        .accessibility(identifier: "projectListElement")
        .fixedSize(horizontal: false, vertical: true)
        .padding(Edge.Set(arrayLiteral: .vertical, .leading))
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
