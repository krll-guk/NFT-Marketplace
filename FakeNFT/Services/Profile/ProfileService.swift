import Foundation

protocol ProfileServiceProtocol {
    func getProfile(with request: NetworkRequest, completion: @escaping (Result<Profile, Error>) -> Void)
    func getProfileNFT(with id: String, completion: @escaping (Result<ProfileNFT, Error>) -> Void)
    func getAuthor(with id: String, completion: @escaping (Result<AuthorName, Error>) -> Void)
    func checkErrors() -> Bool
}

final class ProfileService: ProfileServiceProtocol {
    private let networkClient: NetworkClient
    private var errors = [String]()

    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }

    func checkErrors() -> Bool {
        if errors.contains(where: { $0 == NetworkClientError.httpStatusCode(429).localizedDescription }) {
            errors = []
            return true
        } else {
            errors = []
            return false
        }
    }

    func getProfile(with request: NetworkRequest, completion: @escaping (Result<Profile, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            self.networkClient.send(
                request: request,
                type: Profile.self
            ) { (result: Result<Profile, Error>) in
                switch result {
                case .success(let profile):
                    DispatchQueue.main.async {
                        completion(.success(profile))
                    }
                case .failure(let error):
                    self.errors.append(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
    }

    func getProfileNFT(with id: String, completion: @escaping (Result<ProfileNFT, Error>) -> Void) {
        if let cached = NFTCache.cacheNFT[Constants.NFT.rawValue + id] {
            return completion(.success(cached))
        }

        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let request = ProfileNFTGetRequest(id: id)
            self.networkClient.send(
                request: request,
                type: ProfileNFT.self
            ) { (result: Result<ProfileNFT, Error>) in
                switch result {
                case .success(let profileNFT):
                    NFTCache.cacheNFT[Constants.NFT.rawValue + id] = profileNFT
                    completion(.success(profileNFT))
                case .failure(let error):
                    self.errors.append(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }

    }

    func getAuthor(with id: String, completion: @escaping (Result<AuthorName, Error>) -> Void) {
        if let cached = NFTCache.cacheAuthor[Constants.author.rawValue + id] {
            return completion(.success(cached))
        }

        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let request = AuthorGetRequest(id: id)
            self.networkClient.send(
                request: request,
                type: AuthorName.self
            ) { (result: Result<AuthorName, Error>) in
                switch result {
                case .success(let author):
                    NFTCache.cacheAuthor[Constants.author.rawValue + id] = author
                    completion(.success(author))
                case .failure(let error):
                    self.errors.append(error.localizedDescription)
                    completion(.failure(error))
                }

            }
        }
    }
}

extension ProfileService {
    private enum Constants: String {
        case author, NFT
    }
}
