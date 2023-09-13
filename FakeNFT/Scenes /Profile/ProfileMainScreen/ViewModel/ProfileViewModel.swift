import Foundation

protocol ProfileViewModelProtocol {
    var showAlertObservable: Observable<Bool> { get }
    var profileObservable: Observable<Profile> { get }
    var profile: Profile { get }
    func syncProfile()
    func setNewProfile(with value: Profile)
    func setProfile(with value: Profile)
    func fetchProfile()
}

final class ProfileViewModel: ProfileViewModelProtocol {
    private let profileService: ProfileServiceProtocol
    private let loader: UIBlockingProgressHUDProtocol

    @Observable
    private var showAlert = false
    var showAlertObservable: Observable<Bool> { $showAlert }

    @Observable
    private(set) var profile: Profile
    var profileObservable: Observable<Profile> { $profile }

    private var newProfile: Profile

    init(profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
        self.loader = UIBlockingProgressHUD()
        self.profile = Profile()
        self.newProfile = Profile()
    }

    func fetchProfile() {
        loader.show()
        let request = ProfileGetRequest()
        profileService.getProfile(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.newProfile = profile
                self.loader.dismiss()
            case .failure:
                switch self.profileService.checkError() {
                case true:
                    DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
                        self.fetchProfile()
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

    func syncProfile() {
        if newProfile != profile || profile == Profile() {
            fetchProfile()
        }
    }

    func setNewProfile(with value: Profile) {
        newProfile = value
    }

    func setProfile(with value: Profile) {
        profile = value
    }
}
