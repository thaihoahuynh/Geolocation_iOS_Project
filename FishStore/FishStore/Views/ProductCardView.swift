//
//  ProductCardView.swift
//  FishStore
//
//  Created by MAY 04 on 8/10/26.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: product.imageName)
                .font(.largeTitle)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 90)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

            Text(product.name)
                .font(.subheadline)
                .lineLimit(1)

            Text("\(Int(product.price)) VND")
                .font(.subheadline).bold()
                .foregroundColor(.red)
        }
        .padding(10)
        .frame(width: 130)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    ProductCardView(product: Product(name: "Neon Tetra",
                                     description: "Freshwater fish",
                                     price: 20000,
                                     imageName: "drop.fill",
                                     stock: 50))
}
