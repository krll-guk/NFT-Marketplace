import Foundation

final class NFTCollectionViewModel {
    
    // MARK: Internal properties
    
    let collectionModel: NFTCollectionModel
    
    // MARK: Private properties
    
    @Observable
    private(set) var userModel: UserModel?
    @Observable
    private(set) var nftModels: Array<NFTModel> = []
    
    private(set) var orderModel: OrderModel?
    private(set) var profileModel: ProfileModel?
    
    private let networkClient = DefaultNetworkClient()
    
    // MARK: Initializers
    
    init(collectionModel: NFTCollectionModel) {
        self.collectionModel = collectionModel
        
        fetchUser(by: collectionModel.authorID)
        fetchNFTs()
        fetchOrder()
        fetchProfile()
    }
    
    // MARK: Internal functions
    
    func getNFTModel(by id: String) -> NFTModel? {
        return nftModels.first(where: { $0.id == id })
    }
    
    // MARK: Private functions
    
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
    
    private func fetchNFTs() {
        networkClient.send(
            request: GetNFTsNetworkRequest(),
            type: [NFTNetworkModel].self
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let networkModels):
                self.nftModels = networkModels.map({ NFTModel(from: $0) })
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
