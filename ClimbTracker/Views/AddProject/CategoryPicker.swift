//
//  ClimbCategoryPicker.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/20/21.
//

import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategory: Category

    var body: some View {
        Picker(selection: $selectedCategory, label: Text("Category")) {
            List(Category.allCases) { category in
                Text(category.displayTitle)
                    .tag(category)
                    .accessibility(identifier: category.rawValue)
            }
        }
        .accessibility(identifier: "categoryPicker")
    }
}

struct ClimbCategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPicker(selectedCategory: .constant(.boulder))
    }
}
