import Foundation

private let baseAPIURL = URL(string: "https://64e794d6b0fd9648b79024d3.mockapi.io/api/v1")!

struct CollectionsNetworkRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "/collections", relativeTo: baseAPIURL)
    }
}

struct CollectionNetworkRequest: NetworkRequest {
    let collectionID: String
    var endpoint: URL? {
        URL(string: "/collections/\(collectionID)", relativeTo: baseAPIURL)
    }
}

struct UserNetworkRequest: NetworkRequest {
    let userID: String
    var endpoint: URL? {
        URL(string: "/users/\(userID)", relativeTo: baseAPIURL)
    }
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
