import Foundation

private let baseAPIURL = URL(string: "https://64e794d6b0fd9648b79024d3.mockapi.io/api/v1")!

struct GetCollectionsNetworkRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "/collections", relativeTo: baseAPIURL)
    }
}

struct GetUserNetworkRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "/users/\(id)", relativeTo: baseAPIURL)
    }
    private let id: String
    
    init(by id: String) {
        self.id = id
    }
}

struct GetNFTsNetworkRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "/nft", relativeTo: baseAPIURL)
    }
}

struct GetOrderNetworkRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "/orders/1", relativeTo: baseAPIURL)
    }
}

struct GetProfileNetworkRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "/profile/1", relativeTo: baseAPIURL)
    }
}

struct PutProfileNetworkRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "/profile/1", relativeTo: baseAPIURL)
    }
    var httpMethod: HttpMethod {
        .put
    }
    var dto: Encodable? {
        putProfileDTO
    }
    private let putProfileDTO: PutProfileDTO
    
    init(with dto: PutProfileDTO) {
        self.putProfileDTO = dto
    }
}

struct PutProfileDTO: Encodable {
    let likes: Array<String>
}

extension String {
    
    var percentEncoded: String {
        guard let encoded = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ""
        }
        return encoded
    }
    
    var percentDecoded: String {
        guard let decoded = removingPercentEncoding else {
            return ""
        }
        return decoded
    }
}
