//
//  User.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 26.08.2023.
//

import Foundation

struct User: Codable {
    let avatar: String
    let name: String
    let description: String
    let website: String
    let nfts: [String]
    let rating: String
    let id: String
}
