//
//  UserViewScreenViewModel.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 26.08.2023.
//

import Foundation

final class UserViewScreenViewModel {
    private let model: UserVIewScreenModel

    var onChange: (() -> Void)?
    var onError: ((_ error: Error, _ retryAction: @escaping () -> Void) -> Void)?

    private(set) var user: User? {
        didSet {
            onChange?()
        }
    }

    init(model: UserVIewScreenModel) {
        self.model = model
    }

    func getUser(userId: String) {
        model.getUser(userId: userId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    self.onError?(error) { [weak self] in
                        self?.getUser(userId: userId)
                    }
                    self.user = nil
                }
            }
        }
    }
}
