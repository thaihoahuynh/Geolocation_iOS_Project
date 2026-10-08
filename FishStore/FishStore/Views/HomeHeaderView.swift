//
//  HomeHeaderView.swift
//  FishStore
//
//  Created by MAY 04 on 8/10/26.
//

import SwiftUI

struct HomeHeaderView: View {
    var storeName: String
    var subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.blue)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(storeName)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            iconButton(systemName: "bell", badge: 3)
            iconButton(systemName: "cart", badge: 2)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func iconButton(systemName: String, badge: Int) -> some View {
        Button { } label: {
            Image(systemName: systemName)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(alignment: .topTrailing) {
                    Text("\(badge)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 4, y: -4)
                }
        }
    }
}

#Preview {
    HomeHeaderView(storeName: "Ornamental Fish 🐟 🐠 🐡", subtitle: "The aquatic world at your fingertips")
}
