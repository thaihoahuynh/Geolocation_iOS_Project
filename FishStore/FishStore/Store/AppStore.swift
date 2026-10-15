//
//  Appstore.swift
//  FishStore
//
//  Created by MAY 04 on 8/10/26.
//

import SwiftUI
import Combine

class AppStore: ObservableObject {
    // MARK: - Catalog
    @Published var categories: [ProductCategory] = []
    @Published var products: [Product] = []

    // MARK: - User data (each property saves itself automatically)
    @Published var cartItems: [CartItem] = [] {
        didSet { save(cartItems, key: "cartItems") }
    }
    @Published var orders: [Order] = [] {
        didSet { save(orders, key: "orders") }
    }
    @Published var favoriteIDs: Set<String> = [] {
        didSet { save(favoriteIDs, key: "favoriteIDs") }
    }
    @Published var customerName = "" {
        didSet { UserDefaults.standard.set(customerName, forKey: "customerName") }
    }
    @Published var customerPhone = "" {
        didSet { UserDefaults.standard.set(customerPhone, forKey: "customerPhone") }
    }
    @Published var deliveryAddress = "" {
        didSet { UserDefaults.standard.set(deliveryAddress, forKey: "deliveryAddress") }
    }

    // MARK: - Store info
    let storeName = "Pretty Fish Store"
    let storeAddress = "Landmark 81, 720A Dien Bien Phu, Binh Thanh, Ho Chi Minh City"
    let storePhone = "0900 000 000"   // replace with your real number
    let storeHours = "8:00 - 21:00, every day"

    let baseShippingFee: Double = 30_000
    let freeShippingThreshold: Double = 500_000

    init() {
        loadCatalog()
        cartItems = load([CartItem].self, key: "cartItems") ?? []
        orders = load([Order].self, key: "orders") ?? []
        favoriteIDs = load(Set<String>.self, key: "favoriteIDs") ?? []

        let defaults = UserDefaults.standard
        customerName = defaults.string(forKey: "customerName") ?? ""
        customerPhone = defaults.string(forKey: "customerPhone") ?? ""
        deliveryAddress = defaults.string(forKey: "deliveryAddress") ?? ""
    }

    // MARK: - Saving and loading

    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    func resetUserData() {
        cartItems = []
        orders = []
        favoriteIDs = []
        customerName = ""
        customerPhone = ""
        deliveryAddress = ""
    }

    // MARK: - Products

    func filteredProducts(for destination: ProductListDestination) -> [Product] {
        products.filter { product in
            (destination.categoryId == nil || product.categoryId == destination.categoryId)
            && (!destination.onSaleOnly || product.oldPrice != nil)
        }
    }

    // MARK: - Favorites

    var favoriteProducts: [Product] {
        products.filter { favoriteIDs.contains($0.id) }
    }

    func isFavorite(_ product: Product) -> Bool {
        favoriteIDs.contains(product.id)
    }

    func toggleFavorite(_ product: Product) {
        if favoriteIDs.contains(product.id) {
            favoriteIDs.remove(product.id)
        } else {
            favoriteIDs.insert(product.id)
        }
    }

    // MARK: - Cart

    var cartCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    var cartSubtotal: Double {
        cartItems.reduce(0) { $0 + $1.total }
    }

    var shippingFee: Double {
        if cartItems.isEmpty || cartSubtotal >= freeShippingThreshold {
            return 0
        }
        return baseShippingFee
    }

    var cartTotal: Double {
        cartSubtotal + shippingFee
    }

    func quantityInCart(of product: Product) -> Int {
        cartItems.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }

    // Never lets the cart go above the stock
    func addToCart(_ product: Product, quantity: Int = 1) {
        let allowed = min(quantity, product.stock - quantityInCart(of: product))
        guard allowed > 0 else { return }

        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += allowed
        } else {
            cartItems.append(CartItem(product: product, quantity: allowed))
        }
    }

    func changeQuantity(of item: CartItem, by amount: Int) {
        guard let index = cartItems.firstIndex(where: { $0.id == item.id }) else { return }
        let newQuantity = cartItems[index].quantity + amount

        if newQuantity <= 0 {
            cartItems.remove(at: index)
        } else if newQuantity <= item.product.stock {
            cartItems[index].quantity = newQuantity
        }
    }

    func removeItems(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }

    // MARK: - Orders

    func placeOrder(customerName: String,
                    phone: String,
                    address: String,
                    payment: PaymentMethod,
                    note: String) {
        guard !cartItems.isEmpty else { return }

        let order = Order(customerName: customerName,
                          phone: phone,
                          address: address,
                          items: cartItems,
                          orderDate: Date(),
                          status: .pending,
                          shippingFee: shippingFee,
                          paymentMethod: payment,
                          note: note)
        orders.insert(order, at: 0)
        cartItems.removeAll()
    }

    func cancelOrder(_ order: Order) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        orders[index].status = .cancelled
    }

    // For demo only: a real shop would update this from its own system
    func advanceStatus(of order: Order) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        switch orders[index].status {
        case .pending: orders[index].status = .preparing
        case .preparing: orders[index].status = .shipping
        case .shipping: orders[index].status = .delivered
        default: break
        }
    }

    // MARK: - Sample catalog

    private func loadCatalog() {
        categories = [
            ProductCategory(id: "fish", name: "Fish", iconName: "drop.fill"),
            ProductCategory(id: "plants", name: "Aquatic Plants", iconName: "leaf.fill"),
            ProductCategory(id: "accessories", name: "Tank Accessories", iconName: "wrench.and.screwdriver.fill"),
            ProductCategory(id: "tanks", name: "Tanks", iconName: "cube.fill"),
            ProductCategory(id: "equipment", name: "Filters & Lights", iconName: "fan.fill"),
            ProductCategory(id: "food", name: "Food", iconName: "fork.knife"),
            ProductCategory(id: "medicine", name: "Medicine & Care", iconName: "cross.case.fill"),
            ProductCategory(id: "shrimp", name: "Shrimp", iconName: "ladybug.fill")
        ]

        products = [
            // Fish
            Product(id: "betta-halfmoon", name: "Halfmoon Betta", categoryId: "fish",
                    description: "A showy betta with a wide, half-moon tail. Males are territorial, so keep one per tank.",
                    price: 85_000, oldPrice: 120_000, imageName: "drop.fill", stock: 30, rating: 4.8,
                    careTip: "Water 24-28°C, pH 6.5-7.5. Feed small portions twice a day."),
            Product(id: "guppy-fancy", name: "Fancy Guppy (pair)", categoryId: "fish",
                    description: "Colorful, peaceful and easy to breed. A great first fish.",
                    price: 45_000, imageName: "drop.fill", stock: 120, rating: 4.6,
                    careTip: "Water 22-28°C. Keep more females than males."),
            Product(id: "neon-tetra", name: "Neon Tetra", categoryId: "fish",
                    description: "Small schooling fish with a bright blue stripe.",
                    price: 20_000, imageName: "drop.fill", stock: 200, rating: 4.7,
                    careTip: "Keep in a group of 6 or more. Water 22-26°C."),
            Product(id: "goldfish-ranchu", name: "Ranchu Goldfish", categoryId: "fish",
                    description: "Round-bodied goldfish with a charming wen on the head.",
                    price: 150_000, oldPrice: 180_000, imageName: "drop.fill", stock: 20, rating: 4.5,
                    careTip: "Needs 40L or more per fish and strong filtration."),
            Product(id: "angelfish-silver", name: "Silver Angelfish", categoryId: "fish",
                    description: "Elegant, tall-finned fish for community tanks.",
                    price: 60_000, imageName: "drop.fill", stock: 8, rating: 4.4,
                    careTip: "Needs a tall tank, 80L or more for a pair."),

            // Plants
            Product(id: "java-fern", name: "Java Fern", categoryId: "plants",
                    description: "A hardy plant that grows well even in low light.",
                    price: 50_000, imageName: "leaf.fill", stock: 40, rating: 4.7,
                    careTip: "Tie it to rock or wood. Do not bury the rhizome."),
            Product(id: "anubias-nana", name: "Anubias Nana", categoryId: "plants",
                    description: "Compact, slow-growing plant with thick dark leaves.",
                    price: 65_000, oldPrice: 80_000, imageName: "leaf.fill", stock: 35, rating: 4.6,
                    careTip: "Attach to decorations. Low light is fine."),
            Product(id: "amazon-sword", name: "Amazon Sword", categoryId: "plants",
                    description: "A large background plant that fills a tank quickly.",
                    price: 45_000, imageName: "leaf.fill", stock: 0, rating: 4.5,
                    careTip: "Plant in nutrient-rich substrate."),

            // Accessories
            Product(id: "driftwood", name: "Natural Driftwood", categoryId: "accessories",
                    description: "Natural wood that gives your tank a forest look.",
                    price: 120_000, imageName: "wrench.and.screwdriver.fill", stock: 18, rating: 4.3,
                    careTip: "Soak for a few days before use."),
            Product(id: "aquarium-gravel", name: "Aquarium Gravel 2kg", categoryId: "accessories",
                    description: "Clean, fine gravel safe for fish and plants.",
                    price: 90_000, imageName: "wrench.and.screwdriver.fill", stock: 50, rating: 4.4,
                    careTip: "Rinse well before adding to the tank."),

            // Tanks
            Product(id: "tank-60cm", name: "Glass Tank 60cm", categoryId: "tanks",
                    description: "Clear glass tank, about 60 liters. Great for a community setup.",
                    price: 850_000, oldPrice: 1_000_000, imageName: "cube.fill", stock: 10, rating: 4.6,
                    careTip: "Place on a flat, stable stand."),
            Product(id: "tank-nano", name: "Nano Cube Tank 30cm", categoryId: "tanks",
                    description: "A small cube tank for a betta or shrimp.",
                    price: 450_000, imageName: "cube.fill", stock: 14, rating: 4.5,
                    careTip: "Ideal for desks and shelves."),

            // Filters and lights
            Product(id: "water-filter", name: "Water Filter", categoryId: "equipment",
                    description: "Quiet internal filter for tanks up to 60cm.",
                    price: 350_000, imageName: "fan.fill", stock: 15, rating: 4.7,
                    careTip: "Clean the sponge every 2 weeks in tank water."),
            Product(id: "led-light", name: "LED Light", categoryId: "equipment",
                    description: "Bright, energy-saving light for planted tanks.",
                    price: 220_000, oldPrice: 280_000, imageName: "lightbulb.fill", stock: 25, rating: 4.5,
                    careTip: "Use 6-8 hours per day."),
            Product(id: "air-pump", name: "Air Pump", categoryId: "equipment",
                    description: "Adds oxygen and gentle water movement.",
                    price: 150_000, imageName: "fan.fill", stock: 22, rating: 4.2,
                    careTip: "Keep the pump above the water line or use a check valve."),

            // Food
            Product(id: "fish-food-flakes", name: "Fish Food Flakes", categoryId: "food",
                    description: "Balanced daily flakes for most tropical fish.",
                    price: 35_000, imageName: "fork.knife", stock: 80, rating: 4.5,
                    careTip: "Feed only what fish finish in 2 minutes."),
            Product(id: "betta-pellets", name: "Betta Pellets", categoryId: "food",
                    description: "Protein-rich floating pellets made for bettas.",
                    price: 40_000, imageName: "fork.knife", stock: 60, rating: 4.6,
                    careTip: "2-3 pellets, twice a day."),

            // Medicine and care
            Product(id: "water-conditioner", name: "Water Conditioner 100ml", categoryId: "medicine",
                    description: "Removes chlorine from tap water so it is safe for fish.",
                    price: 55_000, imageName: "cross.case.fill", stock: 70, rating: 4.8,
                    careTip: "Add every time you change water."),
            Product(id: "anti-fungal", name: "Anti-Fungal Treatment", categoryId: "medicine",
                    description: "Helps treat white spots and fungal infections.",
                    price: 70_000, oldPrice: 85_000, imageName: "cross.case.fill", stock: 28, rating: 4.4,
                    careTip: "Follow the dose on the label. Remove carbon from the filter."),

            // Shrimp
            Product(id: "cherry-shrimp", name: "Red Cherry Shrimp (5 pcs)", categoryId: "shrimp",
                    description: "Hardy little shrimp that keep your tank clean.",
                    price: 50_000, imageName: "ladybug.fill", stock: 60, rating: 4.7,
                    careTip: "Avoid copper medicines. Water 20-26°C.")
        ]
    }
}
