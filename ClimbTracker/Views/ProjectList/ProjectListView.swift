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
        // TODO: fix constraint complaints
        NavigationView {
            ScrollView {
                LazyVStack(alignment:.leading) {
                    ForEach(viewModel.projects, id: \.id) { project in
                        ProjectListElementView(project: project)
                        Divider()
                    }
                }
            }
            .navigationTitle(Text("Projects"))
            .toolbar() {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Project") {
                        presentingAddClimb.toggle()
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
    static var previews: some View {
        let viewModel = ProjectListViewModel()
        viewModel.projects = (0...20).map { i in
            let id = UUID(),
                climbedAt = Date().addingTimeInterval(TimeInterval.random(in: (-600000...600000)))

            if i % 2 == 0 {
                let ropeGrade = YosemiteDecimalGrade.allCases[Int.random(in: (0..<YosemiteDecimalGrade.allCases.count))]
                if Bool.random() {
                    return Project<TopRopeCategory>(id: id,
                                                  climbedAt: climbedAt,
                                                  grade: ropeGrade)
                } else {
                    return Project<SportCategory>(id: id,
                                                climbedAt: climbedAt,
                                                grade: ropeGrade)
                }

            } else {
                let boulderGrade = HuecoGrade.allCases[Int.random(in: (0..<HuecoGrade.allCases.count))]
                return Project<BoulderCategory>(id: id,
                                              climbedAt: climbedAt,
                                              grade: boulderGrade)
            }
        }
        let addClimbView = AddProjectView(addClimbViewModel: AddProjectViewModel())
        return ProjectListView(
            addProjectViewFactory: { addClimbView },
            viewModel: viewModel
        )
    }
}
