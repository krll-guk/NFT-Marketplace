import Foundation

protocol ProfileViewModelProtocol {
    var profileObservable: Observable<Profile> { get }
    var profile: Profile { get }
    func syncProfile()
    func setNewProfile(with value: Profile)
    func setProfile(with value: Profile)
}

final class ProfileViewModel: ProfileViewModelProtocol {
    private let profileService: ProfileServiceProtocol

    @Observable
    private(set) var profile: Profile
    var profileObservable: Observable<Profile> { $profile }

    private var newProfile: Profile

    init(profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
        self.profile = Profile()
        self.newProfile = Profile()
        self.fetchProfile()
    }

    private func fetchProfile() {
        showLoader(true)
        let request = ProfileGetRequest()
        profileService.getProfile(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.newProfile = profile
                self.showLoader(false)
            case .failure:
                self.fetchProfile()
            }
        }
    }

    func syncProfile() {
        if newProfile != profile {
            fetchProfile()
        }
    }

    func setNewProfile(with value: Profile) {
        newProfile = value
    }

    func setProfile(with value: Profile) {
        profile = value
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
