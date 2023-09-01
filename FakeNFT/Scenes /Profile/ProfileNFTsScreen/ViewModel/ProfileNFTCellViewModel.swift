import Foundation

typealias ProfileNFTCellViewModels = [ProfileNFTCellViewModel]

struct ProfileNFTCellViewModel {
    let name: String
    let rating: Int
    let author: String
    let price: String
    let isLiked: Bool

    init(from: ProfileNFT, isLiked: Bool) {
        self.name = from.name
        self.rating = from.rating
        self.author = from.author
        self.price = String(from.price)
        self.isLiked = isLiked
    }
}
