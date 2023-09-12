import UIKit

struct NFTCartManager {
    let networkClient: NetworkClient
    
    func fetchNFTs(completion: @escaping (Result<[NFTServerModel], Error>) -> Void) {
        fetchCart { result in
            switch result {
            case .success(let models):
                let dispatchGroup = DispatchGroup()
                var nfts: [NFTServerModel] = []

                for id in models.nfts {
                    dispatchGroup.enter()
                    fetchNFTs(id: id) { nftResult in
                        defer {
                            dispatchGroup.leave()
                        }

                        switch nftResult {
                        case .success(let nft):
                            nfts.append(nft)
                        case .failure(let error):
                            print(error.localizedDescription)
                            // Handle the error if needed
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    completion(.success(nfts))
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }

    private func fetchCart(completion: @escaping (Result<Order, Error>) -> Void) {
        let request = NFTNetworkRequest(
            endpoint: URL(string: Constants.ordersAPI.rawValue)!,
            httpMethod: .get,
            dto: nil)
        networkClient.send(request: request,
                           type: Order.self,
                           onResponse: completion)
    }
    
    private func fetchNFTs(id: String, completion: @escaping (Result<NFTServerModel, Error>) -> Void) {
        let request = NFTNetworkRequest(
            endpoint: URL(string: Constants.nftAPI.rawValue + "\(id)")!,
            httpMethod: .get,
            dto: nil)
        networkClient.send(request: request,
                           type: NFTServerModel.self,
                           onResponse: completion)
    }
    
    func removeNFTFromCart(id: String, nfts: [String], completion: @escaping (Result<Order, Error>) -> Void) {
        let request = NFTNetworkRequest(
            endpoint: URL(string: Constants.ordersAPI.rawValue)!,
            httpMethod: .put,
            dto: Order(id: id, nfts: nfts))
        networkClient.send(request: request, type: Order.self, onResponse: completion)
    }
    
    func addNFTFromStatistics(id: String, nfts: [String], completion: @escaping (Result<Order, Error>) -> Void) {
        let request = NFTNetworkRequest(
            endpoint: URL(string: Constants.ordersAPI.rawValue),
            httpMethod: .put,
            dto: Order(id: id, nfts: nfts))
        networkClient.send(request: request, type: Order.self, onResponse: completion)
    }
}
