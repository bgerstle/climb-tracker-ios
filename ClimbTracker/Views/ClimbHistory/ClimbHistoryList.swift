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
            ForEach(viewModel.createdClimbs) { climb in
                ClimbHistoryRow(climbAttributes: climb.attributes)
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
        if case .created(let climb) = Climb.create(attributes: ClimbAttributes(climbedAt: Date(), kind: .boulder(grade: .easy))).event {
            viewModel.createdClimbs = [
                climb
            ]
        }
        let addClimbView = AddClimbView(climbService: nil)
        return ClimbHistoryList(
            addClimbViewFactory: { addClimbView },
            viewModel: viewModel
        )
    }
}
