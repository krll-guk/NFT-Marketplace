import Foundation

typealias ProfileNFTCellViewModels = [ProfileNFTCellViewModel]

struct ProfileNFTCellViewModel {
    let url: URL?
    let name: String
    let rating: Int
    let author: String
    let price: String
    let isLiked: Bool

    init(from: ProfileNFT, isLiked: Bool, author: String) {
        self.url = URL(string: from.images[0])
        self.name = from.name
        self.rating = from.rating
        self.author = author
        self.price = String(from.price)
        self.isLiked = isLiked
    }
}
