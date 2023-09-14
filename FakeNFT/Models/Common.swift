//
//  Common.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 26.08.2023.
//

import Foundation

struct Request: NetworkRequest {
    var endpoint: URL?
    var queryParameters: [String: String]?
    var httpMethod: HttpMethod
}
