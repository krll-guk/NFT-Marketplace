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
    
    // MARK: Internal functions
    
    func sortCatalogs(by type: SortType) {
        switch type {
        case .title:
            catalogModels.sort(by: { $0.title < $1.title })
        case .count:
            catalogModels.sort(by: { $0.nftIDs.count > $1.nftIDs.count })
        }
        SortTypeStorage.shared.sortType = type
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
                self.sortCatalogs(by: SortTypeStorage.shared.sortType)
            case .failure(let error):
                print(error)
            }
        }
    }
}
