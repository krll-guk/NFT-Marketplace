import Foundation

protocol ProfileViewModelProtocol {
    func fetchProfile()
    var profileObservable: Observable<Profile> { get }
    var profile: Profile { get }
}

final class ProfileViewModel: ProfileViewModelProtocol {
    private let profileService: ProfileServiceProtocol

    @Observable
    private(set) var profile: Profile
    var profileObservable: Observable<Profile> { $profile }

    init(profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
        self.profile = Profile()
    }

    func fetchProfile() {
        showLoader(true)
        let request = ProfileGetRequest()
        profileService.getProfile(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.showLoader(false)
            case .failure:
                self.fetchProfile()
            }
        }
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
