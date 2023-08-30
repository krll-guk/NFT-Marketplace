import Foundation

private let baseAPIURL = URL(string: "https://64e794d6b0fd9648b79024d3.mockapi.io/api/v1")!

struct NFTCatalogNetworkRequest: NetworkRequest {
    var endpoint = URL(string: "/collections", relativeTo: baseAPIURL)
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
