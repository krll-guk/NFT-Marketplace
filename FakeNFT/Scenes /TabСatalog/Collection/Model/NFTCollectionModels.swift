import Foundation

struct NFTCollectionModel {
    let id: String
    let coverLink: String
    let name: String
    let authorID: String
    let description: String
    let nftIDs: Array<String>
    
    init(from model: CollectionNetworkModel) {
        self.id = model.id
        self.coverLink = model.cover
        self.name = model.name
        self.authorID = model.author
        self.description = model.description
        self.nftIDs = model.nfts
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

struct NFTModel {
    let id: String
    let imageLink: String
    let rating: Int
    let name: String
    let price: Double
    
    init(from model: NFTNetworkModel) {
        self.id = model.id
        self.imageLink = model.images.first ?? ""
        self.rating = model.rating
        self.name = model.name
        self.price = model.price
    }
}

struct OrderModel {
    let id: String
    let inCartNFTIDs: Array<String>
    
    init(from model: OrderNetworkModel) {
        self.id = model.id
        self.inCartNFTIDs = model.nfts
    }
}

struct ProfileModel {
    let id: String
    let likedNFTIDs: Array<String>
    
    init(from model: ProfileNetworkModel) {
        self.id = model.id
        self.likedNFTIDs = model.likes
    }
}
