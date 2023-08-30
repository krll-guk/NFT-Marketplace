import Foundation

struct NFTCatalogModel {
    let coverLink: String
    let caption: String
    
    init(from model: NFTCatalogNetworkModel) {
        self.coverLink = model.cover
        self.caption = "\(model.name) (\(model.nfts.count))"
    }
}
