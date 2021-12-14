//
//  ProjectList.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/2/21.
//

import SwiftUI

struct ProjectListView: View {
    @State private var presentingAddProject: Bool = false

    typealias AddProjectViewFactory = () -> AddProjectView

    private let addProjectViewFactory: AddProjectViewFactory

    @ObservedObject
    private var viewModel: ProjectListViewModel

    init(addProjectViewFactory: @escaping AddProjectViewFactory, viewModel: ProjectListViewModel) {
        self.addProjectViewFactory = addProjectViewFactory
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.projects, id: \.id) { projectSummary in
                    NavigationLink(
                        destination: ProjectDetailsView(projectId: projectSummary.id,
                                                        projectCategory: projectSummary.category)
                    ) {
                        ProjectListElementView(project: projectSummary)
                    }.swipeActions() {
                        // FIXME: update "focused" project to prevent losing it after resorting
                        // e.g. adding attempt to an older project makes it jump to the top
                        Button {
                            viewModel.logAttempt(project: projectSummary,
                                                 didSend: true)
                        } label: {
                            Label("Send", systemImage: "checkmark")
                        }
                        .accessibilityIdentifier("addProjectSendAction")
                        .tint(.green)
                        
                        Button {
                            viewModel.logAttempt(project: projectSummary,
                                                 didSend: false)
                        } label: {
                            Label("Attempt", systemImage: "plus")
                        }
                        .accessibilityIdentifier("addProjectAttemptAction")
                        .tint(.gray)
                    }
                }
            }
            .navigationTitle(Text("Projects"))
            .toolbar() {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        presentingAddProject.toggle()
                    } label: {
                        Label("New", systemImage: "plus")
                    }
                    .accessibility(identifier: "addProjectButton")
                }
            }
            .sheet(isPresented: $presentingAddProject, content: addProjectViewFactory)
        }
        // fixes nav bar layout constraint issues: https://stackoverflow.com/a/66299785/600467
        .navigationViewStyle(StackNavigationViewStyle())
        .accessibility(identifier: "projectList")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ProjectListViewModel(projectService: previewProjectService)
        viewModel.projects = (0...5).map { i in
            if i % 2 == 0 {
                let ropeGrade = YosemiteDecimalGrade.allCases[Int.random(in: (0..<YosemiteDecimalGrade.allCases.count))]
                return ProjectSummary(id: UUID(),
                                      category: .rope,
                                      createdAt: Date(),
                                      grade: ropeGrade.rawValue,
                                      sendCount: 0,
                                      sessionDates: Set(),
                                      attemptCount: 1,
                                      lastAttempt: Date())
            } else {
                let boulderGrade = HuecoGrade.allCases[Int.random(in: (0..<HuecoGrade.allCases.count))]
                return ProjectSummary(id: UUID(),
                                      category: .boulder,
                                      createdAt: Date(),
                                      grade: boulderGrade.rawValue,
                                      sendCount: 0,
                                      sessionDates: Set(),
                                      attemptCount: 1,
                                      lastAttempt: Date())
            }
        }

        return ProjectListView(
            addProjectViewFactory: { AddProjectView(viewModel: previewAddProjectViewModel) },
            viewModel: viewModel
        )
    }
}
