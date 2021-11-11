//
//  ClimbHistoryList.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/2/21.
//

import SwiftUI

struct ProjectListView: View {
    @State private var presentingAddClimb: Bool = false

    typealias AddProjectViewFactory = () -> AddProjectView
    // FIXME: remove !
    private let addProjectViewFactory: AddProjectViewFactory!
    @ObservedObject private var viewModel: ProjectListViewModel

    init(addProjectViewFactory: AddProjectViewFactory!, viewModel: ProjectListViewModel!) {
        self.addProjectViewFactory = addProjectViewFactory
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.projects, id: \.id) { projectSummary in
                    if #available(iOS 15.0, *) {
                        ProjectListElementView(project: projectSummary).swipeActions() {
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
                    } else {
                        fatalError("Shouldn't happen. Xcode requires this check even though deployment target is iOS 15.")
                    }
                }
            }
            .navigationTitle(Text("Projects"))
            .toolbar() {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        presentingAddClimb.toggle()
                    } label: {
                        Label("New", systemImage: "plus")
                    }
                    .accessibility(identifier: "addProjectButton")
                }
            }
            .sheet(isPresented: $presentingAddClimb, content: addProjectViewFactory)
        }
        // fixes nav bar layout constraint issues: https://stackoverflow.com/a/66299785/600467
        .navigationViewStyle(StackNavigationViewStyle())
        .accessibility(identifier: "projectList")
    }
}

struct ContentView_Previews: PreviewProvider {
    class DummyServices : RopeProjectService, BoulderProjectService {
        func create<G: BoulderGrade>(grade: G) {}

        func create<G: RopeGrade>(grade: G) {}

        func attempt(projectId: UUID, at: Date, didSend: Bool, subcategory: RopeProject.Subcategory) {}

        func attempt(projectId: UUID, at: Date, didSend: Bool) {}
    }

    static var previews: some View {
        let viewModel = ProjectListViewModel(ropeProjectService: DummyServices(),
                                             boulderProjectService: DummyServices())
        viewModel.projects = (0...20).map { i in
            if i % 2 == 0 {
                let ropeGrade = YosemiteDecimalGrade.allCases[Int.random(in: (0..<YosemiteDecimalGrade.allCases.count))]
                return ProjectSummary(id: UUID(),
                                      category: .rope,
                                      grade: ropeGrade.rawValue,
                                      didSend: true,
                                      attemptCount: 1,
                                      title: "Title")
            } else {
                let boulderGrade = HuecoGrade.allCases[Int.random(in: (0..<HuecoGrade.allCases.count))]
                return ProjectSummary(id: UUID(),
                                      category: .boulder,
                                      grade: boulderGrade.rawValue,
                                      didSend: true,
                                      attemptCount: 1,
                                      title: "Title")
            }
        }
        let addClimbView = AddProjectView(addClimbViewModel: AddProjectViewModel())
        return ProjectListView(
            addProjectViewFactory: { addClimbView },
            viewModel: viewModel
        )
    }
}
