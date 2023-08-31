import Foundation

struct NFTCatalogModel {
    let id: String
    let coverLink: String
    let caption: String
    
    init(from model: CollectionNetworkModel) {
        self.id = model.id
        self.coverLink = model.cover
        self.caption = "\(model.name) (\(model.nfts.count))"
    }
}
