//
//  UserVIewScreenModel.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 26.08.2023.
//

import Foundation
import Kingfisher

final class UserVIewScreenModel {
    private let defaultNetworkClient = DefaultNetworkClient()

    func getUser(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        let request = Request(endpoint: URL(string: Config.baseUrl + "/users" + "/\(userId)"), httpMethod: .get)
        defaultNetworkClient.send(request: request, type: User.self, onResponse: completion)
    }
}
