import Foundation
protocol CartViewModelProtocol: AnyObject {
    var cartModels: [NFTCartModel] { get }
    var isPlaceholderHidden: Bool { get }
    var isTableViewHidden: Bool { get }
    var showAlert: ((String) -> Void)? { get set }
    func viewDidLoad(completion: @escaping () -> Void)
    func didDeleteNFT(at index: Int)
    func didSortByPrice()
    func didSortByRating()
    func didClearAfterPurchase()
    func didSortByName()
    func isCartEmpty()
}

final class CartViewModel: CartViewModelProtocol {
    var showAlert: ((String) -> Void)?
    
    @Observable
    var cartModels: [NFTCartModel] = []
    
    @Observable
    var isPlaceholderHidden: Bool = true
    
    @Observable
    var isTableViewHidden: Bool = true
    
    private let model: NFTCartManager
    
    init(model: NFTCartManager) {
        self.model = model
    }
    
    func viewDidLoad(completion: @escaping () -> Void) {
        UIBlockingProgressHUD.show()
        model.fetchNFTs { nfts in
            DispatchQueue.main.async { [weak self] in
                switch nfts {
                case .success(let models):
                    let viewModels = models.map(NFTCartModel.init(serverModel:))
                    self?.cartModels = viewModels
                    completion()
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.showAlert?("Не удалось загрузить данные. Повторите попытку.")
                }
            }
        }
        UIBlockingProgressHUD.dismiss()
    }
    
    func didDeleteNFT(at index: Int) {
        cartModels.remove(at: index)
        model.removeNFTFromCart(id: "1",
                                nfts: cartModels.map { $0.id }) { result in
            switch result {
            case .success(let order):
                print("\(order.id) successfully deleted")
            case .failure(let error):
                print("\(error.localizedDescription) couldn't delete")
            }
        }
    }
    
    func didClearAfterPurchase() {
        cartModels.removeAll()
        model.clearCartAfterPurchase(id: "1", nfts: cartModels.map {$0.id }) { result in
            switch result {
            case .success(let order):
                print("\(order.id) successfully deleted")
            case .failure(let failure):
                print("\(failure.localizedDescription) couldn't delete cart")
            }
        }
    }
    
    func didAddNFT(nft: NFTCartModel, at index: Int) {
        cartModels.insert(nft, at: index)
        model.addNFTFromStatistics(id: "1",
                                   nfts: cartModels.map { $0.id }) { result in
            switch result {
            case .success(let order):
                print("\(order.id) successfully added")
            case .failure(let error):
                print("\(error.localizedDescription) couldn't add NFT")
            }
        }
    }
    
    func didSortByPrice() {
        cartModels.sort { $0.price > $1.price}
    }
    
    func didSortByRating() {
        cartModels.sort { $0.rating.rawValue > $1.rating.rawValue}
    }
    
    func didSortByName() {
        cartModels.sort { $0.name > $1.name }
    }
    
    func isCartEmpty() {
        if cartModels.isEmpty {
            isPlaceholderHidden = false
            isTableViewHidden = true
            // return
        } else {
            isTableViewHidden = false
            isPlaceholderHidden = true
        }
    }
    
    func bindCart() {
        isCartEmpty()
        self.$cartModels.bind {[weak self] _ in
            self?.isCartEmpty()
        }
    }
}
