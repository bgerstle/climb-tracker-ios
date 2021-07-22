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
                    ForEach(viewModel.createdClimbs) { climb in
                        ClimbHistoryRow(climbAttributes: climb.attributes)
                        Divider()
                    }
                }
            }
            .navigationTitle("Climbs")
            .navigationBarItems(trailing:
                Button("Log Climb") {
                    presentingAddClimb.toggle()
                }
                .accessibility(identifier: "addClimbButton")
            )
            .sheet(isPresented: $presentingAddClimb, content: addClimbViewFactory)
        }
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
                let ropeGrade = RopeGrade.allCases[Int.random(in: (0..<RopeGrade.allCases.count))]
                if Bool.random() {
                    return Climb(id: id,
                                 attributes: Climb.Attributes(climbedAt: climbedAt,
                                                              grade: ropeGrade,
                                                              category: TopRopeCategory.self))
                } else {
                    return Climb(id: id,
                                 attributes: Climb.Attributes(climbedAt: climbedAt,
                                                              grade: ropeGrade,
                                                              category: SportCategory.self))
                }

            } else {
                let boulderGrade = BoulderGrade.allCases[Int.random(in: (0..<BoulderGrade.allCases.count))]
                return Climb(id: id,
                             attributes: Climb.Attributes(climbedAt: climbedAt,
                                                          grade: boulderGrade,
                                                          category: BoulderCategory.self))
            }
        }
        let addClimbView = AddClimbView(addClimbViewModel: AddClimbViewModel())
        return ClimbHistoryList(
            addClimbViewFactory: { addClimbView },
            viewModel: viewModel
        )
    }
}
