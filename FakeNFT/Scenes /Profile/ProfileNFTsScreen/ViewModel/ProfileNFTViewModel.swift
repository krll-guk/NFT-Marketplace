import Foundation

protocol ProfileNFTViewModelProtocol {
    var profile: Profile { get }
    var profileNFTsObservable: Observable<ProfileNFTCellViewModels> { get }
    var pickedSortTypeObservable: Observable<ProfileNFTsSortType?> { get }
    var hidePlaceholder: Bool { get }
    var sorted: ProfileNFTCellViewModels { get }
    func insertIndex() -> Int
    func changeType(_ type: ProfileNFTsSortType)
    func getCellViewModel(at indexPath: IndexPath) -> ProfileNFTCellViewModel
}

final class ProfileNFTViewModel: ProfileNFTViewModelProtocol {
    private let profileService: ProfileServiceProtocol
    private let loader: UIBlockingProgressHUDProtocol

    private(set) var hidePlaceholder: Bool = false
    private(set) var sorted = ProfileNFTCellViewModels()
    
    let profile: Profile
    private var nft: ProfileNFT?
    private var index = 0

    @StoredProperty("ProfileNFTsSortType", defaultValue: ProfileNFTsSortType.byRating)
    private var storedSortType: ProfileNFTsSortType

    @Observable
    private var pickedSortType: ProfileNFTsSortType?
    var pickedSortTypeObservable: Observable<ProfileNFTsSortType?> { $pickedSortType }

    @Observable
    private var profileNFTs = ProfileNFTCellViewModels()
    var profileNFTsObservable: Observable<ProfileNFTCellViewModels> { $profileNFTs }

    init(_ profile: Profile, profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
        self.loader = UIBlockingProgressHUD()
        self.profile = profile
        if !profile.nfts.isEmpty {
            loader.show()
            fetchProfileNFT()
            hidePlaceholder = true
        }
    }

    func insertIndex() -> Int {
        guard let index = sorted.firstIndex(where: { $0.id == nft?.id }) else { return 0 }
        return index
    }

    func changeType(_ type: ProfileNFTsSortType) {
        loader.show()
        pickedSortType = type
        storedSortType = type
        sort()
        loader.dismiss()
    }

    private func fetchProfileNFT() {
        if profileNFTs.count < profile.nfts.count {
            let id = profile.nfts[index]
            profileService.getProfileNFT(with: id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let nft):
                    self.index += 1
                    self.fetchAuthorName(with: nft)
                case .failure:
                    self.fetchProfileNFT()
                }
            }
        } else {
            loader.dismiss()
        }
    }

    private func fetchAuthorName(with nft: ProfileNFT) {
        profileService.getAuthor(with: nft.author) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let author):
                self.nft = nft
                self.sorted.append(
                    ProfileNFTCellViewModel(from: nft,
                                            isLiked: self.isLiked(),
                                            author: author.name)
                )
                self.sort()
                self.profileNFTs = self.sorted
                self.fetchProfileNFT()
            case .failure:
                self.fetchAuthorName(with: nft)
            }
        }
    }

    private func isLiked() -> Bool {
        return profile.likes.contains { $0 == nft?.id }
    }

    private func sort() {
        switch storedSortType {
        case .byPrice:
            sorted.sort { $0.price > $1.price }
        case .byRating:
            sorted.sort { ($0.rating, $0.price) > ($1.rating, $1.price) }
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
