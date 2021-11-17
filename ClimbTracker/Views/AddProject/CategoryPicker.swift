//
//  ClimbCategoryPicker.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/20/21.
//

import SwiftUI

extension ProjectCategory : Identifiable {
    var displayTitle: String {
        switch self {
        case .boulder:
            return "Boulder"
        case .rope:
            return "Rope"
        }
    }

    var id: ProjectCategory { self }
}

struct CategoryPicker: View {
    @Binding var selectedCategory: ProjectCategory

    var body: some View {
        Picker(selection: $selectedCategory, label: Text("Category")) {
            List(ProjectCategory.allCases) { category in
                Text(category.displayTitle)
                    .tag(category)
                    .accessibility(identifier: category.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .accessibility(identifier: "categoryPicker")
    }
}

struct ProjectCategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPicker(selectedCategory: .constant(.boulder))
    }
}
