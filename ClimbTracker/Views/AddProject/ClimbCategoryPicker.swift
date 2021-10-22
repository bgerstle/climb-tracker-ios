//
//  ClimbCategoryPicker.swift
//  ClimbTracker
//
//  Created by Brian Gerstle on 7/20/21.
//

import SwiftUI

extension Category: Identifiable {
    var displayTitle: String {
        switch self {
        case .boulder:
            return "Boulder"
        case .sport:
            return "Sport"
        case .topRope:
            return "Top Rope"
        }
    }

    var id: String { rawValue }
}

struct CategoryPicker: View {
    @Binding var selectedCategory: Category

    var body: some View {
        Picker(selection: $selectedCategory, label: Text("Category")) {
            ForEach(Category.allCases) { category in
                Text(category.displayTitle)
            }
        }
    }
}

struct ClimbCategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPicker(selectedCategory: .constant(.boulder))
    }
}
