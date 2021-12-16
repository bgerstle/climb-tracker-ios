//
//  ProjectDetailsView.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/10/21.
//

import SwiftUI

extension RopeProject.Subcategory {
    var attemptListDescription: String {
        switch self {
        case .sport:
            return "Sport"
        case .topRope:
            return "Top Rope"
        }
    }
}

struct ProjectDetailsView: View {
    @EnvironmentObject var viewModel: ProjectDetailsViewModel

    let projectId: ProjectID
    let projectCategory: ProjectCategory

    @State private var presentingEditProject: Bool = false

    @State private var attemptToEdit: ErasedAttempt? = nil

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
        Group {
            if let project = viewModel.project {
                // TODO: sort by attemptedAt
                ForEach(project.attempts, id: \.id) { attempt in
                    AttemptListRow(attempt: attempt)
                    // using swipe actions because tapping isn't working right
                    // probably because the hit area is obscured by child views
                        .swipeActions() {
                        Button {
                            attemptToEdit = ErasedAttempt(attempt)
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    var body: some View {
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
        .onDisappear {
            viewModel.unsubscribe()
        }
//        .toolbar() {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Edit") {
//                    presentingEditProject.toggle()
//                }
//                .accessibility(identifier: "editProjectButton")
//            }
//        }
        .navigationTitle(viewModel.projectName ?? "")
        .sheet(
            item: $attemptToEdit,
            onDismiss: {
                attemptToEdit = nil
            },
            content: { wrappedAttempt in
                EditAttemptView(projectId: projectId, attempt: wrappedAttempt.attempt)
            })
    }
}

struct ProjectDetailsView_Previews: PreviewProvider {
    static var boulderProjectDetailsView: some View {
        let viewModel = ProjectDetailsViewModel(projectService: previewProjectService, projectNameService: previewProjectNameService)
        let boulderProjCreated = BoulderProject.Event.Created(
            projectId: UUID(),
            createdAt: Date(),
            grade: .hueco(HuecoGrade.four)
        )
        viewModel.update(projectType: BoulderProject.self, envelope: EventEnvelope(event: .created(boulderProjCreated), timestamp: Date()))
        viewModel.update(projectType: BoulderProject.self, envelope: EventEnvelope(
            event: .attempted(BoulderProject.Event.Attempted(
                projectId: boulderProjCreated.projectId,
                attemptId: UUID(),
                didSend: false,
                attemptedAt: Date()
            )),
            timestamp: Date()
        ))
        viewModel.update(projectType: BoulderProject.self, envelope: EventEnvelope(
            event: .attempted(BoulderProject.Event.Attempted(
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
