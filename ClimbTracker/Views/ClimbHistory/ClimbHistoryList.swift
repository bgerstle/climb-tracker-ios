//
//  ClimbHistoryList.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/2/21.
//

import SwiftUI

struct ClimbHistoryList: View {
    @State private var presentingAddClimb: Bool = false

    typealias AddClimbViewFactory = () -> AddClimbView
    // FIXME: remove !
    private let addClimbViewFactory: AddClimbViewFactory!
    @ObservedObject private var viewModel: ClimbHistoryViewModel

    init(addClimbViewFactory: AddClimbViewFactory!, viewModel: ClimbHistoryViewModel!) {
        self.addClimbViewFactory = addClimbViewFactory
        self.viewModel = viewModel
    }

    var body: some View {
        // TODO: fix constraint complaints
        NavigationView {
            ScrollView {
                LazyVStack(alignment:.leading) {
                    ForEach(viewModel.createdClimbs, id: \.id) { climb in
                        ClimbHistoryRow(climb: climb)
                        Divider()
                    }
                }
            }
            .navigationTitle(Text("Climbs"))
            .toolbar() {
                ToolbarItem(placement: .primaryAction) {
                    Button("Log Climb") {
                        presentingAddClimb.toggle()
                    }
                    .accessibility(identifier: "addClimbButton")
                }
            }
            .sheet(isPresented: $presentingAddClimb, content: addClimbViewFactory)
        }
        // fixes nav bar layout constraint issues: https://stackoverflow.com/a/66299785/600467
        .navigationViewStyle(StackNavigationViewStyle())
        .accessibility(identifier: "climbHistoryList")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ClimbHistoryViewModel()
        viewModel.createdClimbs = (0...20).map { i in
            let id = UUID(),
                climbedAt = Date().addingTimeInterval(TimeInterval.random(in: (-600000...600000)))

            if i % 2 == 0 {
                let ropeGrade = YosemiteDecimalGrade.allCases[Int.random(in: (0..<YosemiteDecimalGrade.allCases.count))]
                if Bool.random() {
                    return Climb<TopRopeCategory>(id: id,
                                                  climbedAt: climbedAt,
                                                  grade: ropeGrade)
                } else {
                    return Climb<SportCategory>(id: id,
                                                climbedAt: climbedAt,
                                                grade: ropeGrade)
                }

            } else {
                let boulderGrade = HuecoGrade.allCases[Int.random(in: (0..<HuecoGrade.allCases.count))]
                return Climb<BoulderCategory>(id: id,
                                              climbedAt: climbedAt,
                                              grade: boulderGrade)
            }
        }
        let addClimbView = AddClimbView(addClimbViewModel: AddClimbViewModel())
        return ClimbHistoryList(
            addClimbViewFactory: { addClimbView },
            viewModel: viewModel
        )
    }
}
