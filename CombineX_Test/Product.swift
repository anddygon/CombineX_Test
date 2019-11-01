// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - List
struct Product: Codable, Equatable {
    let quantity: String
    let weburl: String
    let price: Price
    let name: String
    let image: String
    let images: [Image]

    enum CodingKeys: String, CodingKey {
        case quantity, weburl, price, name, image, images
    }
    
    static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Product {
    // MARK: - Price
    struct Price: Codable {
        let price: String
        let priceValue: Double
        let value: String
        let code: String
        let rate: String

        enum CodingKeys: String, CodingKey {
            case price
            case priceValue = "price_value"
            case value, code, rate
        }
    }
    
    struct Image: Codable {
        let image: String
    }
}
