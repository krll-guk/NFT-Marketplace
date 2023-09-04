import Foundation

final class NFTCatalogViewModel {
    
    // MARK: Private properties
    
    @Observable
    private(set) var catalogModels: Array<NFTCatalogModel> = []
    
    private let networkClient = DefaultNetworkClient()
    
    // MARK: Initializers
    
    init() {
        fetchCatalogs()
    }
    
    // MARK: Private functions
    
    private func fetchCatalogs() {
        networkClient.send(
            request: GetCollectionsNetworkRequest(),
            type: [CollectionNetworkModel].self
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let networkModels):
                self.catalogModels = networkModels.map({ NFTCatalogModel(from: $0) })
            case .failure(let error):
                print(error)
            }
        }
    }
}
