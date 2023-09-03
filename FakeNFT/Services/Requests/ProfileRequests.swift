import Foundation

enum ProfileConstants {
    static let profileURL = URL(string: "https://64e794d6b0fd9648b79024d3.mockapi.io/api/v1/profile/1")
    static let NFTBaseURLString = "https://64e794d6b0fd9648b79024d3.mockapi.io/api/v1/nft/"
    static let AuthorBaseURLString = "https://64e794d6b0fd9648b79024d3.mockapi.io/api/v1/users/"
}

struct ProfileGetRequest: NetworkRequest {
    var endpoint: URL? { ProfileConstants.profileURL }
}

struct ProfilePutRequest: NetworkRequest {
    private let profile: ProfileEdited

    init(_ profile: ProfileEdited) {
        self.profile = profile
    }

    var endpoint: URL? { ProfileConstants.profileURL }
    var httpMethod: HttpMethod { .put }
    var dto: Encodable? { profile }
}

struct ProfileNFTGetRequest: NetworkRequest {
    private let id: String

    init(id: String) {
        self.id = id
    }

    var endpoint: URL? { URL(string: ProfileConstants.NFTBaseURLString + id) }
}

struct AuthorGetRequest: NetworkRequest {
    private let id: String

    init(id: String) {
        self.id = id
    }

    var endpoint: URL? { URL(string: ProfileConstants.AuthorBaseURLString + id) }
}

struct ProfileLikesPutRequest: NetworkRequest {
    private let profile: ProfileLikes

    init(profile: ProfileLikes) {
        self.profile = profile
    }

    var endpoint: URL? { ProfileConstants.profileURL }
    var httpMethod: HttpMethod { .put }
    var dto: Encodable? { profile }
}
