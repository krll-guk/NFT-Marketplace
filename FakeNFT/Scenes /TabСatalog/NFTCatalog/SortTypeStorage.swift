import Foundation

enum SortType: String {
    case title
    case count
}

final class SortTypeStorage {
    
    // MARK: Internal properties
    
    static let shared = SortTypeStorage()
    
    var sortType: SortType {
        get {
            let value = storage.string(forKey: Key.sortType.rawValue) ?? ""
            return SortType(rawValue: value) ?? .count
        }
        set {
            storage.set(newValue.rawValue, forKey: Key.sortType.rawValue)
        }
    }
    
    // MARK: Private properties
    
    private let storage = UserDefaults.standard
    
    // MARK: Initializers
    
    private init() {}
}

private enum Key: String {
    case sortType
}
