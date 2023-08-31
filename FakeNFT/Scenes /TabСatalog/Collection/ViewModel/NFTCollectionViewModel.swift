import Foundation

final class NFTCollectionViewModel {
    
    private let networkClient = DefaultNetworkClient()
    
    @Observable
    private(set) var collectionModel: NFTCollectionModel?
    
    @Observable
    private(set) var userModel: UserModel?
    
    // MARK: Initializers
    
    init(collectionID: String) {
        fetchCollection(by: collectionID)
    }
    
    // MARK: Private functions
    
    private func fetchCollection(by id: String) {
        networkClient.send(
            request: CollectionNetworkRequest(collectionID: id),
            type: CollectionNetworkModel.self
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let networkModel):
                let model = NFTCollectionModel(from: networkModel)
                self.collectionModel = model
                self.fetchUser(by: model.authorID)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchUser(by id: String) {
        networkClient.send(
            request: UserNetworkRequest(userID: id),
            type: UserNetworkModel.self
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let networkModel):
                self.userModel = UserModel(from: networkModel)
            case .failure(let error):
                print(error)
            }
        }
    }
}
