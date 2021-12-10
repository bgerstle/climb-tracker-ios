//
//  ProjectDetailsView.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/10/21.
//

import SwiftUI

struct ProjectDetailsView: View {
    @EnvironmentObject var viewModel: ProjectDetailsViewModel

    let projectId: ProjectID

    var body: some View {
        Text(viewModel.project?.name ?? "")
            .accessibilityIdentifier("projectDetailsView")
            .onAppear {
                viewModel.projectId = self.projectId
            }
    }
}

struct ProjectDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailsView(projectId: UUID())
    }
}
