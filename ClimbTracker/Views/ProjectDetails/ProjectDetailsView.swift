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
    let projectCategory: ProjectCategory

    @State private var presentingEditProject: Bool = false

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    struct ProjectAttributeRow : View {
        let attributeName: String
        let attributeValue: String

        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: 5.0) {
                Text(attributeName)
                    .fontWeight(.bold)
                Spacer()
                Text(attributeValue)
                    .accessibilityIdentifier("projectAttributeValueLabel")
            }
            .accessibilityIdentifier("projectAttributeRow")
        }
    }

    func header() -> some View {
        VStack {
            ProjectAttributeRow(
                attributeName: "Grade",
                attributeValue: viewModel.project?.rawGrade ?? "")
            ProjectAttributeRow(
                attributeName: "Created At",
                attributeValue: (viewModel.project?.createdAt).map(ProjectDetailsView.dateFormatter.string) ?? "")
        }
    }

    func attemptsList() -> some View {
        ForEach(viewModel.project?.attempts ?? [], id: \.id) { attempt in
            HStack {
                Text(attempt.didSend ? "Send" : "Attempt")
                Spacer()
                Text(ProjectDetailsView.dateFormatter.string(from: attempt.attemptedAt))
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // TODO: make the header scroll w/ list content
                header()
                    .padding()
                Form {
                    Section("Attempts") {
                        attemptsList()
                    }
                }
            }
            .onAppear {
                viewModel.subscribe(projectId: projectId, category: projectCategory)
            }
            .toolbar() {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        presentingEditProject.toggle()
                    }
                    .accessibility(identifier: "editProjectButton")
                }
            }
            // TODO: get project name
            .navigationTitle("Project Name")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProjectDetailsView_Previews: PreviewProvider {
    static var boulderProjectDetailsView: some View {
        let viewModel = ProjectDetailsViewModel(projectService: previewProjectService)
        let boulderProjCreated = BoulderProject.Created(
            projectId: UUID(),
            createdAt: Date(),
            grade: .hueco(HuecoGrade.four)
        )
        viewModel.updateProject(EventEnvelope(event: .created(boulderProjCreated), timestamp: Date()))
        viewModel.updateProject(EventEnvelope(
            event: .attempted(BoulderProject.Attempted(
                projectId: boulderProjCreated.projectId,
                attemptId: UUID(),
                didSend: false,
                attemptedAt: Date()
            )),
            timestamp: Date()
        ))
        viewModel.updateProject(EventEnvelope(
            event: .attempted(BoulderProject.Attempted(
                projectId: boulderProjCreated.projectId,
                attemptId: UUID(),
                didSend: true,
                attemptedAt: Date().addingTimeInterval(600)
            )),
            timestamp: Date()
        ))

        return ProjectDetailsView(projectId: boulderProjCreated.projectId,
                                  projectCategory: .boulder)
            .environmentObject(viewModel)
    }

    static var previews: some View {
        boulderProjectDetailsView
    }
}
