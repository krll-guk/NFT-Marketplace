import Foundation

protocol CurrencyViewModelProtocol: AnyObject {
    var currencies: [CurrencyModel] { get }
    var isPaymentSuccesful: Bool { get }
    
    func viewDidLoad(completion: @escaping () -> Void)
    func sendGetPayment(selectedId: String, completion: @escaping (Bool) -> Void)
}

final class CurrencyViewModel: CurrencyViewModelProtocol {

    @Observable
    var currencies: [CurrencyModel] = []
    
    @Observable
    var isPaymentSuccesful: Bool = false
    
    private var selectedCurrency: CurrencyServerModel?
    private let model: CurrencyManager
    
    private let cartViewModel: CartViewModelProtocol?
    
    init(model: CurrencyManager, cartViewModel: CartViewModelProtocol) {
        self.model = model
        self.cartViewModel = cartViewModel
    }
    
    func viewDidLoad(completion: @escaping () -> Void) {
        UIProgressHUD.show()
        model.fetchCurrencies { currencies in
            DispatchQueue.main.async {
                switch currencies {
                case .success(let currencies):
                    UIProgressHUD.dismiss()
                    let models = currencies.map(CurrencyModel.init(serverModel:))
                    self.currencies = models
                    completion()
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    func sendGetPayment(selectedId: String, completion: @escaping (Bool) -> Void) {
        model.fetchCurrencyById(currencyId: selectedId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currency):
                    self?.handleCurrencyFetchSuccess(currency, completion: completion)
                case.failure(let error):
                    print("couldn't pay \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleCurrencyFetchSuccess(_ currency: CurrencyServerModel, completion: @escaping ((Bool) -> Void)) {
        self.model.getPayment(with: currency.id) { [weak self] result in
            switch result {
            case .success(let payment):
                self?.isPaymentSuccesful = payment.success
                self?.handlePaymentSuccess(completion: completion)
            case .failure(let error):
                print("\(error.localizedDescription) couldn't handle currency")
            }
        }
    }
    
    private func handlePaymentSuccess(completion: @escaping ((Bool) -> Void)) {
        model.getProfileWithNFTs(id: "1") { [weak self] result in
            switch result {
            case .success(let profile):
                self?.updateProfile(with: profile, completion: completion)
                print("\(profile) ADDED NFTS")
            case.failure(let error):
                print("couldn't handle payment \(error.localizedDescription)")
            }
        }
    }
    
    private func updateProfile(with existingProfile: ProfileNFTsModel,
                               completion: @escaping ((Bool) -> Void)) {
        if let nfts = cartViewModel?.cartModels.map({ $0.id }) {
            let updateNFTs = Array(Set(existingProfile.nfts + nfts))
            model.updateProfileWithNFTs(
                id: "1",
                nfts: updateNFTs) {[weak self] result in
                    switch result {
                    case.success(let profile):
                        print(profile)
                        self?.cartViewModel?.didClearAfterPurchase()
                        completion(true)
                    case.failure(let error):
                        print("unable to update profile \(error.localizedDescription)")
                    }
                }
        }
    }
}
