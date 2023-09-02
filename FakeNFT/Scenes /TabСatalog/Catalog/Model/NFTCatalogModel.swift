import Foundation

struct NFTCatalogModel {
    let id: String
    let coverLink: String
    let title: String
    let authorID: String
    let description: String
    let nftIDs: Array<String>
    let caption: String
    
    init(from model: CollectionNetworkModel) {
        self.id = model.id
        self.coverLink = model.cover
        self.title = model.name
        self.authorID = model.author
        self.description = model.description
        self.nftIDs = model.nfts
        self.caption = "\(model.name) (\(model.nfts.count))"
    }
}
