//
//  NFTCollectionViewScreenViewModel.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 31.08.2023.
//

import Foundation

final class NFTCollectionViewScreenViewModel {
    private let model: NFTCollectionViewScreenModel
    private var cartManager: NFTCartManager = NFTCartManager(networkClient: DefaultNetworkClient())

    var onChange: (() -> Void)?
    var onError: ((_ error: Error, _ retryAction: @escaping () -> Void) -> Void)?
    
    private(set) var nftsIds: [Int]?
    private(set) var nfts: [Nft] = [] { didSet { onChange?() }}
    
    public var cartItemsIds: [String] = [] { didSet { onChange?() }}
    public var likes: [String] = [] { didSet { onChange?() }}

    init(model: NFTCollectionViewScreenModel, ids: [Int]? ) {
        self.model = model

        self.nftsIds = ids
    }

    func getUserNfts(showLoader: @escaping (_ active: Bool) -> Void ) {
        guard let ids = nftsIds, !ids.isEmpty else { return }
        showLoader(true)
        
        model.fetchNfts(ids: ids) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let nfts):
                    self.nfts = nfts
                case .failure(let error):
                    self.onError?(error) { [weak self] in
                        self?.getUserNfts(showLoader: showLoader)
                    }
                }
                showLoader(false)
            }
        }
    }
    
    func fetchCart(showLoader: @escaping (_ active: Bool) -> Void ) {
        showLoader(true)
        
        cartManager.fetchNFTs { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let nfts):
                    self.cartItemsIds = nfts.map { $0.id }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                showLoader(false)
            }
        }
    }
    
    func fetchProfile(showLoader: @escaping (_ active: Bool) -> Void ) {
        showLoader(true)
        
        model.getProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.likes = user.likes
                case .failure(let error):
                    print(error.localizedDescription)
                }
                showLoader(false)
            }
        }
    }
    
    func toggleLikes(likes: [String], showLoader: @escaping (_ active: Bool) -> Void ) {
        showLoader(true)

        model.toggleLikes(likes: likes) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.likes = profile.likes
                case .failure(let error):
                    print(error.localizedDescription)
                }
                showLoader(false)
            }
        }
    }
}
