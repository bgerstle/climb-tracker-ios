//
//  ClimbCategoryPicker.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/20/21.
//

import SwiftUI

extension ProjectCategory {
    var displayTitle: String {
        switch self {
        case .boulder:
            return "Boulder"
        case .route:
            return "Route"
        }
    }
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
        .accessibility(identifier: "categoryPicker")
    }
}

struct ClimbCategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPicker(selectedCategory: .constant(.boulder))
    }
}
