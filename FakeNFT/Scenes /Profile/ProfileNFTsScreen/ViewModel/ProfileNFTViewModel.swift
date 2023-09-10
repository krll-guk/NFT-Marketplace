import Foundation

protocol ProfileNFTViewModelProtocol {
    var showAlertObservable: Observable<Bool> { get }
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
    private var nfts: [String]

    @Observable
    private var showAlert = false
    var showAlertObservable: Observable<Bool> { $showAlert }

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
        self.nfts = profile.nfts
        if !profile.nfts.isEmpty {
            loader.show()
            fetch()
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

    private func fetch() {
        let group = DispatchGroup()

        nfts.forEach {
            group.enter()
            profileService.getProfileNFT(with: $0) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let nft):
                    group.enter()
                    self.fetchAuthorName(with: nft) {
                        group.leave()
                    }
                case .failure:
                    break
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if self.profile.nfts.count == self.profileNFTs.count {
                self.loader.dismiss()
            } else {
                switch self.profileService.checkErrors() {
                case true:
                    DispatchQueue.global().asyncAfter(deadline: .now() + 8) {
                        self.fetch()
                    }
                case false:
                    DispatchQueue.main.async {
                        self.loader.dismiss()
                        self.showAlert.toggle()
                    }
                }
            }
        }
    }

    private func fetchAuthorName(with nft: ProfileNFT, completion: @escaping () -> Void) {
        profileService.getAuthor(with: nft.author) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let author):
                self.nfts = self.nfts.filter { $0 != nft.id }
                DispatchQueue.main.async {
                    self.nft = nft
                    self.sorted.append(
                        ProfileNFTCellViewModel(from: nft,
                                                isLiked: self.isLiked(),
                                                author: author.name)
                    )
                    self.sort()
                    self.profileNFTs = self.sorted
                }
            case .failure:
                break
            }
            completion()
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
