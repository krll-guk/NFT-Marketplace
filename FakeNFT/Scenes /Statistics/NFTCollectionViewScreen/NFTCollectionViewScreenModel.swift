//
//  NFTCollectionViewModel.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 31.08.2023.
//

import Foundation

final class NFTCollectionViewScreenModel {
    let networkClient = DefaultNetworkClient()
    
    func fetchNfts(ids: [Int], completion: @escaping (Result<[Nft], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var resultNfts: [Nft] = []
        
        for id in ids {
            dispatchGroup.enter()
            
            let request = Request(endpoint: URL(string: Config.baseUrl + "/nft" + "/\(id)"), httpMethod: .get)
            networkClient.send(request: request, type: Nft.self) { result in
                switch result {
                case .success(let nft):
                    resultNfts.append(nft)
                case .failure(let error):
                    print("Error: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(resultNfts))
        }
    }
    
    func getProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        let request = NFTNetworkRequest(endpoint: URL(string: Config.baseUrl + "/profile/1"), httpMethod: .get)
        
        networkClient.send(request: request, type: Profile.self, onResponse: completion)
    }
    
    func toggleLikes(likes: [String], completion: @escaping (Result<Profile, Error>) -> Void) {
        let request = NFTNetworkRequest(
            endpoint: URL(string: Config.baseUrl + "/profile/1"),
            httpMethod: .put,
            dto: Favorites(likes: likes))
        
        networkClient.send(request: request, type: Profile.self, onResponse: completion)
    }
}
