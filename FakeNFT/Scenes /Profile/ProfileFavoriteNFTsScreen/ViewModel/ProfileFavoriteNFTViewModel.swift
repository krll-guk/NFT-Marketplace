import Foundation

protocol ProfileFavoriteNFTViewModelProtocol {
    var showAlertObservable: Observable<Bool> { get }
    var hidePlaceholderObservable: Observable<Bool> { get }
    var profileNFTsObservable: Observable<ProfileFavoriteNFTCellViewModels> { get }
    var profileObservable: Observable<Profile> { get }
    var newProfileFavoriteNFTs: ProfileFavoriteNFTCellViewModels { get }
    var hidePlaceholder: Bool { get }
    var profile: Profile { get }
    func checkLikes(at indexPath: IndexPath)
    func syncLikes() -> Bool
    func insertIndex() -> Int
    func getCellViewModel(at indexPath: IndexPath) -> ProfileFavoriteNFTCellViewModel
}

final class ProfileFavoriteNFTViewModel: ProfileFavoriteNFTViewModelProtocol {
    private let profileService: ProfileServiceProtocol
    private let loader: UIBlockingProgressHUDProtocol

    private(set) var newProfileFavoriteNFTs = ProfileFavoriteNFTCellViewModels()
    private var newLikes: ProfileLikes
    private var likes: [String]
    private var nft: ProfileNFT?

    @Observable
    private var showAlert = false
    var showAlertObservable: Observable<Bool> { $showAlert }

    @Observable
    private(set) var hidePlaceholder: Bool = false
    var hidePlaceholderObservable: Observable<Bool> { $hidePlaceholder }

    @Observable
    private(set) var profile: Profile
    var profileObservable: Observable<Profile> { $profile }

    @Observable
    private var profileFavoriteNFTs = ProfileFavoriteNFTCellViewModels()
    var profileNFTsObservable: Observable<ProfileFavoriteNFTCellViewModels> { $profileFavoriteNFTs }

    init(_ profile: Profile, profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
        self.loader = UIBlockingProgressHUD()
        self.profile = profile
        self.newLikes = ProfileLikes(likes: profile.likes)
        self.likes = profile.likes
        if !profile.likes.isEmpty {
            loader.show()
            fetch()
            hidePlaceholder = true
        }
    }

    func insertIndex() -> Int {
        guard let index = newProfileFavoriteNFTs.firstIndex(where: { $0.id == nft?.id }) else { return 0 }
        return index
    }

    private func fetch() {
        let group = DispatchGroup()

        likes.forEach {
            group.enter()
            fetchNFT(with: $0) {
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if self.profile.likes.count == self.profileFavoriteNFTs.count {
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

    private func fetchNFT(with id: String, completion: @escaping () -> Void) {
        profileService.getProfileNFT(with: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let nft):
                self.likes = self.likes.filter { $0 != id }
                DispatchQueue.main.async {
                    self.nft = nft
                    self.newProfileFavoriteNFTs.append(ProfileFavoriteNFTCellViewModel(from: nft))
                    self.newProfileFavoriteNFTs = self.profile.likes.reversed().compactMap { id in
                        self.newProfileFavoriteNFTs.first(where: { id == $0.id })
                    }
                    self.profileFavoriteNFTs = self.newProfileFavoriteNFTs
                }
            case .failure:
                break
            }
            completion()
        }
    }

    private func updateProfileLikes() {
        let request = ProfileLikesPutRequest(newLikes)
        profileService.getProfile(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.loader.dismiss()
            case .failure:
                switch self.profileService.checkErrors() {
                case true:
                    DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
                        self.updateProfileLikes()
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

    func checkLikes(at indexPath: IndexPath) {
        let likes = profile.likes.filter { $0 != newProfileFavoriteNFTs[indexPath.row].id }
        newLikes = ProfileLikes(likes: likes)

        newProfileFavoriteNFTs.remove(at: indexPath.row)

        if newLikes.likes.isEmpty {
            hidePlaceholder = false
        }
    }

    func syncLikes() -> Bool {
        if profile.likes == newLikes.likes {
            return true
        } else {
            loader.show()
            updateProfileLikes()
            return false
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> ProfileFavoriteNFTCellViewModel {
        return newProfileFavoriteNFTs[indexPath.row]
    }
}
