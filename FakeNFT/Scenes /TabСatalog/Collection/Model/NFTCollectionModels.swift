import Foundation

struct NFTCollectionModel {
    let id: String
    let coverLink: String
    let name: String
    let authorID: String
    let description: String
    
    init(from model: CollectionNetworkModel) {
        self.id = model.id
        self.coverLink = model.cover
        self.name = model.name
        self.authorID = model.author
        self.description = model.description
    }
}

struct UserModel {
    let id: String
    let name: String
    let website: String
    
    init(from model: UserNetworkModel) {
        self.id = model.id
        self.name = model.name
        self.website = model.website
    }
}
