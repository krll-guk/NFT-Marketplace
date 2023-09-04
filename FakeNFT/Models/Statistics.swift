//
//  Statistics.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 26.08.2023.
//

enum StatSortType: String {
    case byName = "BYNAME"
    case byRatingAsc = "BYRATING_ASC"
    case byRatingDesc = "BYRATING_DESC"
}

struct Nft: Codable {
    let createdAt: String
    let name: String
    let images: [String]
    let rating: Int
    let description: String
    let price: Double
    let id: String
}
