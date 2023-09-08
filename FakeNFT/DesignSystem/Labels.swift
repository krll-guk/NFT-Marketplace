import Foundation

extension String {

    // MARK: - TabBar

    enum TabBar {
        static let profile = NSLocalizedString("", value: "Профиль", comment: "")
        static let catalog = NSLocalizedString("", value: "Каталог", comment: "")
        static let cart = NSLocalizedString("", value: "Корзина", comment: "")
        static let statistics = NSLocalizedString("", value: "Статистика", comment: "")
    }

    // MARK: - Profile

    enum ProfileTable {
        static let myNFTs = NSLocalizedString("", value: "Мои NFT", comment: "")
        static let myLikes = NSLocalizedString("", value: "Избранные NFT", comment: "")
        static let about = NSLocalizedString("", value: "О разработчике", comment: "")
    }

    enum ProfileEdit {
        static let name = NSLocalizedString("", value: "Имя", comment: "")
        static let description = NSLocalizedString("", value: "Описание", comment: "")
        static let website = NSLocalizedString("", value: "Сайт", comment: "")
        static let changePhoto = NSLocalizedString("", value: "Сменить фото", comment: "")
    }

    enum ProfileNFTTableViewCell {
        static let from = NSLocalizedString("", value: "от", comment: "")
        static let price = NSLocalizedString("", value: "Цена", comment: "")
        static let currency = NSLocalizedString("", value: " ETH", comment: "")
    }

    enum ProfileNFTSortAlert {
        static let title = NSLocalizedString("", value: "Сортировка", comment: "")
        static let byPrice = NSLocalizedString("", value: "По цене", comment: "")
        static let byRating = NSLocalizedString("", value: "По рейтингу", comment: "")
        static let byName = NSLocalizedString("", value: "По названию", comment: "")
        static let cancel = NSLocalizedString("", value: "Закрыть", comment: "")
    }

    enum ProfileNFT {
        static let placeholder = NSLocalizedString("", value: "У Вас ещё нет NFT", comment: "")
    }

    enum ProfileFavoriteNFT {
        static let placeholder = NSLocalizedString("", value: "У Вас ещё нет избранных NFT", comment: "")
    }
}
