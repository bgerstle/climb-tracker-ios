//
//  ProjectDetailsView.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/10/21.
//

import SwiftUI

struct ProjectDetailsView: View {
    @EnvironmentObject var viewModel: ProjectDetailsViewModel

    let projectSummary: ProjectSummary

    var body: some View {
        Text(viewModel.project?.rawGrade ?? "")
            .accessibilityIdentifier("projectDetailsView")
            .onAppear {
                viewModel.subscribe(projectId: projectSummary.id,
                                    category: projectSummary.category)
            }
    }
}

//struct ProjectDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectDetailsView()
//    }
//}
