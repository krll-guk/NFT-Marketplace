import Foundation

protocol ProfileFavoriteNFTViewModelProtocol {
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

    private(set) var newProfileFavoriteNFTs = ProfileFavoriteNFTCellViewModels()
    private var newLikes: ProfileLikes
    private var index = 0

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
        self.profile = profile
        self.newLikes = ProfileLikes(likes: profile.likes)
        if !profile.likes.isEmpty {
            showLoader(true)
            fetchProfileNFT()
            hidePlaceholder = true
        }
    }

    func insertIndex() -> Int {
        return newProfileFavoriteNFTs.count - 1
    }

    private func fetchProfileNFT() {
        if profileFavoriteNFTs.count < profile.likes.count {
            let id = profile.likes[index]
            profileService.getProfileNFT(with: id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let nft):
                    self.index += 1
                    self.newProfileFavoriteNFTs.append(
                        ProfileFavoriteNFTCellViewModel(from: nft)
                    )
                    self.profileFavoriteNFTs = self.newProfileFavoriteNFTs
                    self.fetchProfileNFT()
                case .failure:
                    self.fetchProfileNFT()
                }
            }
        } else {
            showLoader(false)
        }
    }

    private func updateProfileLikes() {
        let request = ProfileLikesPutRequest(newLikes)
        profileService.getProfile(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.showLoader(false)
            case .failure:
                self.updateProfileLikes()
            }
        }
    }

    func checkLikes(at indexPath: IndexPath) {
        newProfileFavoriteNFTs = newProfileFavoriteNFTs.filter {
            $0.id != newProfileFavoriteNFTs[indexPath.row].id
        }

        var likes = [String]()
        newLikes.likes.forEach {
            if $0 != newLikes.likes[indexPath.row] {
                likes.append($0)
            }
        }
        newLikes = ProfileLikes(likes: likes)

        if newLikes.likes.isEmpty {
            hidePlaceholder = false
        }
    }

    func syncLikes() -> Bool {
        if profile.likes == newLikes.likes {
            return true
        } else {
            showLoader(true)
            updateProfileLikes()
            return false
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> ProfileFavoriteNFTCellViewModel {
        return newProfileFavoriteNFTs[indexPath.row]
    }

    private func showLoader(_ isShow: Bool) {
        switch isShow {
        case true:
            UIBlockingProgressHUD.show()
        case false:
            UIBlockingProgressHUD.dismiss()
        }
    }
}
