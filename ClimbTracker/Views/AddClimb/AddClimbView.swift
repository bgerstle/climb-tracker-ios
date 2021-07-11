//
//  NewClimbView.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/10/21.
//

import SwiftUI

struct AddClimbView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {

        }
        .accessibility(identifier: "addClimbView")
    }
}

struct NewClimbView_Previews: PreviewProvider {
    static var previews: some View {
        AddClimbView()
    }
}
