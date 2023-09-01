import Foundation

final class NFTCollectionViewModel {
    
    private let networkClient = DefaultNetworkClient()
    
    @Observable
    private(set) var collectionModel: NFTCollectionModel?
    
    @Observable
    private(set) var userModel: UserModel?
    
    @Observable
    private(set) var nftList: Array<NFTModel> = []
    
    @Observable
    private(set) var orderModel: OrderModel?
    
    @Observable
    private(set) var profileModel: ProfileModel?
    
    // MARK: Initializers
    
    init(collectionID: String) {
        fetchCollection(by: collectionID)
        fetchNFTList()
        fetchOrder()
        fetchProfile()
    }
    
    // MARK: Internal functions
    
    func getNFT(by id: String) -> NFTModel? {
        return nftList.first(where: { $0.id == id })
    }
    
    // MARK: Private functions
    
    private func fetchCollection(by id: String) {
        networkClient.send(
            request: GetCollectionNetworkRequest(by: id),
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
            request: GetUserNetworkRequest(by: id),
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
    
    private func fetchNFTList() {
        networkClient.send(
            request: GetNFTsNetworkRequest(),
            type: [NFTNetworkModel].self
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let networkModels):
                self.nftList = networkModels.map({ NFTModel(from: $0) })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchOrder() {
        networkClient.send(
            request: GetOrderNetworkRequest(),
            type: OrderNetworkModel.self
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let networkModel):
                self.orderModel = OrderModel(from: networkModel)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchProfile() {
        networkClient.send(
            request: GetProfileNetworkRequest(),
            type: ProfileNetworkModel.self
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let networkModel):
                self.profileModel = ProfileModel(from: networkModel)
            case .failure(let error):
                print(error)
            }
        }
    }
}
