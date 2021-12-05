//
//  Product.swift
//  Jade
//
//  Created by Nindi Gill on 29/11/21.
//

import Foundation

struct Product: Decodable, Identifiable {

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "product"
        case version = "version"
        case releaseDate = "releaseDate"
        case current = "currentShippingVersion"
        case hotfix = "hotfix"
        case releaseNotes = "releaseNotesUrl"
    }

    static let baseURL: String = "https://account.jamf.com/api/v1/release-versions"

    static var example: Product {
        Product(
            id: 356,
            type: .jamfPro,
            version: "10.0.0",
            releaseDate: "2017-10-31T05:00:00.000Z",
            current: false,
            hotfix: false,
            releaseNotes: ""
        )
    }

    var id: Int
    var type: ProductType
    var version: String
    var releaseDate: String?
    var current: Bool
    var hotfix: Bool
    var releaseNotes: String?
    var downloadLinks: [DownloadLink] = []
    var downloadLinksURL: URL? {
        URL(string: "\(Product.baseURL)/\(id)/download-links")
    }
}
