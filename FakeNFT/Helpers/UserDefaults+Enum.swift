import Foundation

@propertyWrapper
struct StoredProperty<T: RawRepresentable> {
    private let key: String
    private let defaultValue: T
    private let storage: UserDefaults

    init(_ key: String, defaultValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: T {
        get {
            guard
                let rawValue = storage.object(forKey: key) as? T.RawValue,
                let value = T(rawValue: rawValue)
            else {
                 return defaultValue
            }
            return value
        }
        set {
            storage.set(newValue.rawValue, forKey: key)
        }
    }
}
