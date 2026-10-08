//
//  CategoryRowView.swift
//  FishStore
//
//  Created by MAY 04 on 8/10/26.
//

import SwiftUI

struct CategoryRowView: View {
    let categories: [ProductCategory]

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories) { cat in
                VStack(spacing: 6) {
                    Image(systemName: cat.iconName)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 56, height: 56)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(14)

                    Text(cat.name)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CategoryRowView(categories: [
        ProductCategory(name: "Fish", iconName: "drop.fill"),
        ProductCategory(name: "Aquatic Plants", iconName: "leaf.fill")
    ])
}
