import Foundation

protocol ProfileEditViewModelProtocol {
    var showAlertObservable: Observable<Bool> { get }
    func setProfileEdited(_ value: ProfileEdited)
    var profileEdited: ProfileEdited { get }
    var profile: Profile { get }
    var profileObservable: Observable<Profile> { get }
}

final class ProfileEditViewModel: ProfileEditViewModelProtocol {
    private let profileService: ProfileServiceProtocol
    private let loader: UIBlockingProgressHUDProtocol

    private(set) var profileEdited: ProfileEdited

    @Observable
    private var showAlert = false
    var showAlertObservable: Observable<Bool> { $showAlert }

    @Observable
    private(set) var profile: Profile
    var profileObservable: Observable<Profile> { $profile }

    init(_ profileEdited: ProfileEdited, profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
        self.loader = UIBlockingProgressHUD()
        self.profileEdited = profileEdited
        self.profile = Profile()
    }

    private func changeProfile() {
        let request = ProfilePutRequest(profileEdited)
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
                        self.changeProfile()
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

    func setProfileEdited(_ value: ProfileEdited) {
        loader.show()
        profileEdited = value
        changeProfile()
    }
}
