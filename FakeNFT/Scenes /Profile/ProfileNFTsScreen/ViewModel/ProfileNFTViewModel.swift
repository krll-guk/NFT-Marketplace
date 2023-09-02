import Foundation

protocol ProfileNFTViewModelProtocol {
    var profileNFTsObservable: Observable<ProfileNFTCellViewModels> { get }
    var pickedSortTypeObservable: Observable<ProfileNFTsSortType?> { get }
    var sorted: ProfileNFTCellViewModels { get }
    var profile: Profile { get }
    func fetchProfileNFT()
    func insertIndex() -> Int
    func changeType(_ type: ProfileNFTsSortType)
    func getCellViewModel(at indexPath: IndexPath) -> ProfileNFTCellViewModel
}

final class ProfileNFTViewModel: ProfileNFTViewModelProtocol {
    private let profileService: ProfileServiceProtocol

    private(set) var profile: Profile
    private var nft: ProfileNFT?
    private(set) var sorted = ProfileNFTCellViewModels()
    private var index = 0

    @StoredProperty("ProfileNFTsSortType", defaultValue: ProfileNFTsSortType.byRating)
    private var storedSortType: ProfileNFTsSortType

    @Observable
    private var pickedSortType: ProfileNFTsSortType?
    var pickedSortTypeObservable: Observable<ProfileNFTsSortType?> { $pickedSortType }

    @Observable
    private(set) var profileNFTs = ProfileNFTCellViewModels()
    var profileNFTsObservable: Observable<ProfileNFTCellViewModels> { $profileNFTs }

    init(_ profile: Profile, profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
        self.profile = profile
    }

    func insertIndex() -> Int {
        guard let index = sorted.firstIndex(where: { $0.name == nft?.name }) else { return 0 }
        return index
    }

    func changeType(_ type: ProfileNFTsSortType) {
        pickedSortType = type
        storedSortType = type
        sort()
    }

    func fetchProfileNFT() {
        if profileNFTs.count < profile.nfts.count {
            let id = profile.nfts[index]
            profileService.getProfileNFT(with: id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let nft):
                    self.index += 1
                    self.nft = nft
                    self.fetchAuthorName(with: nft)
                case .failure(let error):
                    self.fetchProfileNFT()
                    print(error)
                }
            }
        }
    }

    private func fetchAuthorName(with nft: ProfileNFT) {
        profileService.getAuthor(with: nft.author) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let author):
                self.sorted.append(
                    ProfileNFTCellViewModel(from: nft,
                                            isLiked: self.isLiked(),
                                            author: author.name)
                )
                self.sort()
                self.profileNFTs = self.sorted
            case .failure(let error):
                self.fetchAuthorName(with: nft)
                print(error)
            }
        }
    }

    private func isLiked() -> Bool {
        return profile.likes.contains { $0 == nft?.id }
    }

    func sort() {
        switch storedSortType {
        case .byPrice:
            sorted.sort { $0.price < $1.price }
        case .byRating:
            sorted.sort { $0.rating < $1.rating }
        case .byName:
            sorted.sort { $0.name < $1.name }
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> ProfileNFTCellViewModel {
        return sorted[indexPath.row]
    }
}

enum ProfileNFTsSortType: String {
    case byPrice, byRating, byName
}
