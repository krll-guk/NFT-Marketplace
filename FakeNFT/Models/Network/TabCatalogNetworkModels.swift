import Foundation

struct CollectionNetworkModel: Codable {
    let createdAt: String
    let name: String
    let cover: String
    let nfts: Array<String>
    let description: String
    let author: String
    let id: String
}

struct UserNetworkModel: Codable {
    let name: String
    let avatar: String
    let description: String
    let website: String
    let nfts: Array<String>
    let rating: String
    let id: String
}
