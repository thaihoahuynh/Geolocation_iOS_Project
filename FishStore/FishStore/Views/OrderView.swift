//
//  OrderView.swift
//  FishStore
//
//  Created by MAY 04 on 8/10/26.
//

import SwiftUI

struct OrderView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            Group {
                if store.orders.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No orders yet")
                            .font(.headline)
                    }
                } else {
                    List(store.orders) { order in
                        OrderRowView(order: order)
                    }
                }
            }
            .navigationTitle("Orders")
        }
    }
}

struct OrderRowView: View {
    @EnvironmentObject var store: AppStore
    let order: Order

    private var isFinished: Bool {
        order.status == .delivered || order.status == .cancelled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Order #\(order.id.uuidString.prefix(6))")
                    .font(.headline)
                Spacer()
                Text(order.status.rawValue)
                    .font(.caption).bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(order.status.color.opacity(0.15))
                    .foregroundColor(order.status.color)
                    .clipShape(Capsule())
            }

            Text(order.orderDate.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(order.items) { item in
                Text("\(item.quantity) x \(item.product.name)")
                    .font(.subheadline)
            }

            Text("\(order.customerName) • \(order.address)")
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                Text("Total: \(order.total.vnd)")
                    .font(.subheadline).bold()
                Spacer()
                if order.status == .pending {
                    Button("Cancel") {
                        store.cancelOrder(order)
                    }
                    .foregroundColor(.red)
                }
                if !isFinished {
                    Button("Next step") {
                        store.advanceStatus(of: order)
                    }
                }
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    OrderView()
        .environmentObject(AppStore())
}
