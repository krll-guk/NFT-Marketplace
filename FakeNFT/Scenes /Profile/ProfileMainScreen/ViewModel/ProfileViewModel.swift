import Foundation

protocol ProfileViewModelProtocol {
    func fetchProfile()
    var profileObservable: Observable<Profile?> { get }
    var profile: Profile? { get }
}

final class ProfileViewModel: ProfileViewModelProtocol {
    private let profileService: ProfileServiceProtocol

    @Observable
    private(set) var profile: Profile?
    var profileObservable: Observable<Profile?> { $profile }

    init(profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
    }

    func fetchProfile() {
        profileService.getProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
            case .failure:
                self.fetchProfile()
            }
        }
    }
}
