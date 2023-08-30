import Foundation

struct NFTCatalogNetworkModel: Codable {
    let createdAt: String
    let name: String
    let cover: String
    let nfts: Array<String>
    let description: String
    let author: String
    let id: String
}
