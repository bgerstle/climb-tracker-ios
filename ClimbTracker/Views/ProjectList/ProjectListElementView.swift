//
//  ProjectListElementView.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/11/21.
//

import SwiftUI

struct ProjectListElementView: View {
    let project: ProjectSummary

    private static let defaultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            if let name = project.name {
                Text(name).padding(.bottom)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(project.grade)
                    .accessibilityIdentifier("projectListElementGrade")
                if let lastAttemptAt = project.lastAttempt {
                    let lastAttemptDisplayTime = ProjectListElementView.defaultFormatter.string(from: lastAttemptAt)
                    Text("Attempted at \(lastAttemptDisplayTime)")
                        .accessibilityIdentifier("projectListElementTitle")
                }
            }

            Text({ () -> String in
                if project.sendCount == 0 {
                    return "Still projecting."
                } else if project.sendCount == 1 {
                    return "Sended!"
                } else {
                    return "Sended \(project.sendCount) times!"
                }
            }())
                .accessibilityIdentifier("projectListElementSendStatus")

            Text("\(project.attemptCount) attempts over \(project.sessionDates.count) sessions.")
                .accessibilityIdentifier("projectListElementAttemptStatus")
        }
        .accessibilityElement(children: .contain)
        .accessibility(identifier: "projectListElement")
        .padding(Edge.Set(arrayLiteral: .vertical, .leading, .trailing))
    }
}

struct ProjectListElementView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListElementView(project: ProjectSummary(id: UUID(),
                                                       category: .boulder,
                                                       createdAt: Date(),
                                                       grade: HuecoGrade.easy.rawValue,
                                                       sendCount: 0,
                                                       sessionDates: Set(),
                                                       attemptCount: 1,
                                                       lastAttempt: Date()))
    }
}
