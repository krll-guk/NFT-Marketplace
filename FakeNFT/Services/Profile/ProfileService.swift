import Foundation

protocol ProfileServiceProtocol {
    func getProfile(with request: NetworkRequest, completion: @escaping (Result<Profile, Error>) -> Void)
    func getProfileNFT(with id: String, completion: @escaping (Result<ProfileNFT, Error>) -> Void)
    func getAuthor(with id: String, completion: @escaping (Result<AuthorName, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {
    private var task: NetworkTask?
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }

    func getProfile(with request: NetworkRequest, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard Thread.isMainThread else { return }
        task?.cancel()

        let task = networkClient.send(
            request: request,
            type: Profile.self
        ) { [weak self] (result: Result<Profile, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    completion(.success(profile))
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        self.task = task
    }

    func getProfileNFT(with id: String, completion: @escaping (Result<ProfileNFT, Error>) -> Void) {
        guard Thread.isMainThread else { return }
        task?.cancel()

        let request = ProfileNFTGetRequest(id: id)
        let task = networkClient.send(
            request: request,
            type: ProfileNFT.self
        ) { [weak self] (result: Result<ProfileNFT, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profileNFT):
                    completion(.success(profileNFT))
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        self.task = task
    }

    func getAuthor(with id: String, completion: @escaping (Result<AuthorName, Error>) -> Void) {
        guard Thread.isMainThread else { return }
        task?.cancel()

        let request = AuthorGetRequest(id: id)
        let task = networkClient.send(
            request: request,
            type: AuthorName.self
        ) { [weak self] (result: Result<AuthorName, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profileNFT):
                    completion(.success(profileNFT))
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        self.task = task
    }
}
