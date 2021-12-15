//
//  AttemptListRow.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/15/21.
//

import SwiftUI

struct AttemptListRow: View {
    let attempt: AnyAttempt

    var body: some View {
        HStack {
            Text(attempt.didSend ? "Send" : "Attempt")

            Group {
                switch attempt.match {
                case .boulder(_):
                    EmptyView()
                case .rope(let ropeAttempt):
                    Text("(\(ropeAttempt.subcategory.attemptListDescription))")
                }
            }

            Spacer()
            Text(ProjectDetailsView.dateFormatter.string(from: attempt.attemptedAt))
        }
    }
}

//struct AttemptListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        AttemptListRow()
//    }
//}
