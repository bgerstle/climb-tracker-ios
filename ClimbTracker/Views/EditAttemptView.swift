//
//  EditAttemptView.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 12/15/21.
//

import SwiftUI

struct EditAttemptView: View {
    let projectId: ProjectID
    let attempt: AnyAttempt

    @State
    var attemptedAt: Date

    @State
    var didSend: Bool

    @State
    var subcategory: RopeProject.Subcategory

    @EnvironmentObject
    var viewModel: EditAttemptViewModel

    @Environment(\.presentationMode) var presentationMode

    init(projectId: ProjectID, attempt: AnyAttempt) {
        self.projectId = projectId
        self.attempt = attempt
        _attemptedAt = State<Date>(initialValue: attempt.attemptedAt)
        _didSend = State<Bool>(initialValue: attempt.didSend)
        switch attempt.match {
        case .boulder(_):
            _subcategory = State<RopeProject.Subcategory>(initialValue: .sport)
        case .rope(let ropeAttempt):
            _subcategory = State<RopeProject.Subcategory>(initialValue: ropeAttempt.subcategory)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Attempted At",
                           selection: $attemptedAt,
                           displayedComponents: [.date, .hourAndMinute])

                Toggle("Did Send", isOn: $didSend)

                switch attempt.match {
                case .rope(_):
                    Picker("Subcategory", selection: $subcategory) {
                        ForEach(RopeProject.Subcategory.allCases, id: \.self) { subcatCase in
                            Text(subcatCase.attemptListDescription).tag(subcatCase)
                        }
                    }
                case .boulder(_):
                    EmptyView()
                }
            }
            .datePickerStyle(.compact)
            .pickerStyle(.segmented)
            .toolbar() {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: save)
                }
            }
        }
    }

    func save() {
        switch attempt.match {
        case .boulder(_):
            Task {
                try await self.viewModel.update(
                    boulderAttempt: BoulderProject.Attempt(
                        id: attempt.id,
                        didSend: didSend,
                        attemptedAt: attemptedAt),
                    projectId: projectId
                )
            }
        case .rope(_):
            Task {
                try await self.viewModel.update(
                    ropeAttempt: RopeProject.Attempt(
                        id: attempt.id,
                        didSend: didSend,
                        subcategory: subcategory,
                        attemptedAt: attemptedAt),
                    projectId: projectId
                )
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditAttemptView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EditAttemptView(
                projectId: UUID(),
                attempt: BoulderProject.Attempt(
                    id: UUID(),
                    didSend: true,
                    attemptedAt: Date()
                ))
            EditAttemptView(
                projectId: UUID(),
                attempt: RopeProject.Attempt(
                    id: UUID(),
                    didSend: true,
                    subcategory: .sport,
                    attemptedAt: Date()
                ))
        }
    }
}
