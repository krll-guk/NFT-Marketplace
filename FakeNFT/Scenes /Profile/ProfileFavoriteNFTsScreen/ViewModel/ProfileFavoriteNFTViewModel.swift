import Foundation

protocol ProfileFavoriteNFTViewModelProtocol {
    var alertType: AlertType { get }
    var showAlertObservable: Observable<AlertType> { get }
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
    func fetch()
    func updateProfileLikes()
}

final class ProfileFavoriteNFTViewModel: ProfileFavoriteNFTViewModelProtocol {
    private let profileService: ProfileServiceProtocol
    private let loader: UIBlockingProgressHUDProtocol

    private(set) var newProfileFavoriteNFTs = ProfileFavoriteNFTCellViewModels()
    private var newLikes: ProfileLikes
    private var likes = [String]()
    private var nft: ProfileNFT?

    @Observable
    private(set) var alertType: AlertType = .loadError
    var showAlertObservable: Observable<AlertType> { $alertType }

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
        if !profile.likes.isEmpty {
            var secondIndex = 4
            if secondIndex > profile.likes.count - 1 {
                secondIndex = profile.likes.count - 1
            }
            self.likes = Array(profile.likes[0...secondIndex])
            fetch()
            hidePlaceholder = true
        }
    }

    func insertIndex() -> Int {
        guard let index = newProfileFavoriteNFTs.firstIndex(where: { $0.id == nft?.id }) else { return 0 }
        return index
    }

    func fetch() {
        loader.show()
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
                return
            }

            if self.profileService.error != nil {
                switch self.profileService.checkError() {
                case true:
                    DispatchQueue.global().asyncAfter(deadline: .now() + 8) {
                        self.fetch()
                    }
                case false:
                    DispatchQueue.main.async {
                        self.loader.dismiss()
                        self.alertType = .loadError
                    }
                }
                return
            }

            if self.profileFavoriteNFTs.count < self.profile.likes.count {
                let firstIndex = self.profileFavoriteNFTs.count
                var secondIndex = self.profileFavoriteNFTs.count + 4
                if secondIndex > self.profile.likes.count - 1 {
                    secondIndex = self.profile.likes.count - 1
                }
                self.likes = Array(self.profile.likes[firstIndex...secondIndex])
                self.fetch()
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

    func updateProfileLikes() {
        loader.show()
        let request = ProfileLikesPutRequest(newLikes)
        profileService.getProfile(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.loader.dismiss()
            case .failure:
                switch self.profileService.checkError() {
                case true:
                    DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
                        self.updateProfileLikes()
                    }
                case false:
                    DispatchQueue.main.async {
                        self.loader.dismiss()
                        self.alertType = .updateError
                    }
                }
            }
        }
    }

    func checkLikes(at indexPath: IndexPath) {
        var likes = [String]()
        newLikes.likes.forEach{
            if $0 != newProfileFavoriteNFTs[indexPath.row].id {
                likes.append($0)
            }
        }
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
            updateProfileLikes()
            return false
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> ProfileFavoriteNFTCellViewModel {
        return newProfileFavoriteNFTs[indexPath.row]
    }
}
