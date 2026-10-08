import SwiftUI

struct ContentView: View {
    @State private var categories: [ProductCategory] = []
    @State private var products: [Product] = []
    @State private var searchText = ""

    private var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        }
        return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HomeHeaderView(storeName: "Pretty Fish Store",
                                   subtitle: "The aquatic world at your fingertips")
                    SearchBarView(text: $searchText)
                    BannerView()
                    CategoryRowView(categories: categories)
                    ProductSectionView(title: "Featured Products",
                                       products: filteredProducts)
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear(perform: loadSampleData)
    }

    private func loadSampleData() {
        guard categories.isEmpty else { return }

        categories = [
            ProductCategory(name: "Fish", iconName: "drop.fill"),
            ProductCategory(name: "Aquatic Plants", iconName: "leaf.fill"),
            ProductCategory(name: "Tank Accessories", iconName: "wrench.and.screwdriver.fill"),
            ProductCategory(name: "Tanks", iconName: "cube.fill"),
            ProductCategory(name: "Food", iconName: "fork.knife"),
            ProductCategory(name: "Medicine & Care", iconName: "cross.case.fill"),
            ProductCategory(name: "Promotions", iconName: "tag.fill"),
            ProductCategory(name: "Advice", iconName: "bubble.left.and.bubble.right.fill")
        ]

        products = [
            Product(name: "Neon Tetra", description: "Small, colorful freshwater fish",
                    price: 20000, imageName: "drop.fill", stock: 100),
            Product(name: "Java Fern", description: "Easy-to-grow aquatic plant",
                    price: 50000, imageName: "leaf.fill", stock: 40),
            Product(name: "Water Filter", description: "Filter for 60cm tanks",
                    price: 350000, imageName: "fan.fill", stock: 15)
        ]
    }
}

#Preview {
    ContentView()
}
