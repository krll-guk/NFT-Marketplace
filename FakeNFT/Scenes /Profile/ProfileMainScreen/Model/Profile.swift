import Foundation

struct Profile: Decodable {
    let name: String
    let avatar: String
    let description: String
    let website: String
    let nfts: [String]
    let likes: [String]
    let id: String
}

struct ProfileEdited: Encodable {
    let name: String
    let description: String
    let website: String
}

struct ProfileLikes: Encodable {
    let likes: [String]
}
