//
//  Product.swift
//  FishStore
//
//  Created by MAY 04 on 8/10/26.
//

import Foundation

struct Product: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: Double
    var imageName: String   
    var stock: Int
}
