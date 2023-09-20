import UIKit

extension UIImage {
    enum TabBar {
        static let profile = UIImage(named: "Profile")
        static let catalog = UIImage(named: "Catalog")
        static let cart = UIImage(named: "Cart")
        static let statistics = UIImage(named: "Statistics")
    }

    enum NFTCard {
        static let heart = UIImage(named: "Heart")
        static let heart_filled = UIImage(named: "heart_filled")
        static let add_cart = UIImage(named: "add-to-card")
        static let remove_cart = UIImage(named: "remove-from-cart")
        static let star = UIImage(named: "Star")
        static let inCart = UIImage(named: "InCart")
        static let notInCart = UIImage(named: "NotInCart")
    }

    enum NavigationBar {
        static let backward = UIImage(named: "Backward")
        static let forward = UIImage(named: "Forward")
        static let close = UIImage(named: "Close")
        static let edit = UIImage(named: "Edit")
        static let sort = UIImage(named: "Sort")
    }

    enum ProfileTable {
        static let chevron = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
    }
    
    enum User {
        static let avatarPlaceholder = UIImage(named: "avatar-placeholder")
    }
}
