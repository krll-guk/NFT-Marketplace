import Foundation

typealias ProfileFavoriteNFTCellViewModels = [ProfileFavoriteNFTCellViewModel]

struct ProfileFavoriteNFTCellViewModel {
    let url: URL?
    let name: String
    let rating: Int
    let price: String
    let id: String

    init(from: ProfileNFT) {
        self.url = URL(string: from.images[0])
        self.name = from.name
        self.rating = from.rating
        self.price = String(from.price)
        self.id = from.id
    }
}
