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
    @Observable
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
    
    func nftModelForCell(at indexPath: IndexPath) -> NFTModel? {
        let id = getNFTID(by: indexPath)
        return nftModels.first(where: { $0.id == id })
    }
    
    func toggleLikeForNFT(at indexPath: IndexPath) {
        guard var likedIDs = profileModel?.likedNFTIDs else {
            return
        }
        let id = getNFTID(by: indexPath)
        
        if let index = likedIDs.firstIndex(of: id) {
            likedIDs.remove(at: index)
        } else {
            likedIDs.append(id)
        }
        updateProfile(using: PutProfileDTO(likes: likedIDs))
    }
    
    // MARK: Private functions
    
    private func getNFTID(by indexPath: IndexPath) -> String {
        return collectionModel.nftIDs[indexPath.item]
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
    
    private func updateProfile(using dto: PutProfileDTO) {
        networkClient.send(
            request: PutProfileNetworkRequest(with: dto),
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
