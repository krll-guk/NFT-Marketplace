import Foundation

final class NFTCatalogViewModel {
    
    private let networkClient = DefaultNetworkClient()
    
    @Observable
    private(set) var catalogList: Array<NFTCatalogModel> = []
    
    // MARK: Initializers
    
    init() {
        fetchCatalogList()
    }
    
    // MARK: Private functions
    
    private func fetchCatalogList() {
        networkClient.send(
            request: GetCollectionsNetworkRequest(),
            type: [CollectionNetworkModel].self
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let networkModels):
                self.catalogList = networkModels.map({ NFTCatalogModel(from: $0) })
            case .failure(let error):
                print(error)
            }
        }
    }
}
