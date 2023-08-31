//
//  StatisticsListViewModel.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 26.08.2023.
//

import Foundation

final class StatisticsListViewModel {
    private let model: StatisticsListModel

    var onChange: (() -> Void)?
    var onError: ((_ error: Error, _ retryAction: @escaping () -> Void) -> Void)?

    private(set) var users: [User] = [] {
        didSet {
            onChange?()
        }
    }

    var sortType: StatSortType? {
        didSet {
            saveSortType()
            sortUsers()
            onChange?()
        }
    }

    init(model: StatisticsListModel) {
        self.model = model
        self.sortType = loadSortType()
    }

    func saveSortType() {
        if let sortType = sortType {
            UserDefaults.standard.set(sortType.rawValue, forKey: Config.usersSortTypeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Config.usersSortTypeKey)
        }
    }

    func loadSortType() -> StatSortType {
        if let rawValue = UserDefaults.standard.string(forKey: Config.usersSortTypeKey),
           let sortType = StatSortType(rawValue: rawValue) {
            return sortType
        } else {
            return .byRatingAsc
        }
    }

    func getUsers(showLoader: @escaping (_ active: Bool) -> Void) {
        showLoader(true)

        model.getUsers { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                    self.sortUsers()
                case .failure(let error):
                    self.onError?(error) { [weak self] in
                        self?.getUsers(showLoader: showLoader)
                    }
                    self.users = []
                }
                showLoader(false)
            }
        }
    }

    private func getSorted(users: [User], by sortType: StatSortType) -> [User] {
        switch sortType {
        case .byName:
            return users.sorted { $0.name < $1.name }
        case .byRatingAsc:
            return users.sorted { Int($0.rating) ?? 0 > Int($1.rating) ?? 0 }
        case .byRatingDesc:
            return users.sorted { Int($0.rating) ?? Int.max < Int($1.rating) ?? Int.max }
        }
    }

    func setSortedType(type: StatSortType) {
        switch type {
        case .byName:
            UserDefaults.standard.set(StatSortType.byName.rawValue, forKey: Config.usersSortTypeKey)
            sortType = .byName
        case .byRatingAsc:
            UserDefaults.standard.set(StatSortType.byRatingAsc.rawValue, forKey: Config.usersSortTypeKey)
            sortType = .byRatingAsc
        case .byRatingDesc:
            UserDefaults.standard.set(StatSortType.byRatingDesc.rawValue, forKey: Config.usersSortTypeKey)
            sortType = .byRatingDesc
        }
    }
 
    private func sortUsers() {
        if let sortType = sortType {
            users = getSorted(users: users, by: sortType)
        }
    }
}
