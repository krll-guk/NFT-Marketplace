//
//  NFTCollectionViewScreenViewController.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 31.08.2023.
//

import UIKit
import ProgressHUD

protocol CollectionCellDelegate: AnyObject {
    func addToCart(id: String)
    func removeFromCart(id: String)
    func toggleLike(id: String)
}

final class NFTCollectionViewScreenViewController: UIViewController {
    private var viewModel: NFTCollectionViewScreenViewModel!
    private var cartManager: NFTCartManager = NFTCartManager(networkClient: DefaultNetworkClient())
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(NFTCollectionCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.NavigationBar.backward, for: .normal)
        button.contentMode = .scaleAspectFit // Set content mode
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // Set the desired size
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onChange = { [weak self] in
            self?.change()
        }
        viewModel.onError = { [weak self] error, retryAction in
            let alert = UIAlertController(title: "Ошибка при загрузке коллекции", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Попробовать снова", style: .default, handler: { _ in
                retryAction()
            }))
            self?.present(alert, animated: true, completion: nil)
        }
        viewModel.getUserNfts { [weak self] active in
            self?.showLoader(isShow: active)
        }
        viewModel.fetchCart { [weak self] active in
            self?.showLoader(isShow: active)
        }
        if viewModel.likes.isEmpty {
            viewModel.fetchProfile { [weak self] active in
                self?.showLoader(isShow: active)
            }
        }
        view.backgroundColor = UIColor.Themed.white
        setupCollectionView()
    }
    
    init(viewModel: NFTCollectionViewScreenViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func change() {
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.Themed.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationController?.navigationBar.tintColor = UIColor.Themed.black
        
        view.addSubview(collectionView)
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if viewModel.nftsIds == nil || viewModel.nftsIds?.isEmpty == true {
            let emptyLabel = UILabel()
            emptyLabel.text = "Коллекция пуста"
            emptyLabel.textColor = UIColor.Themed.black
            emptyLabel.textAlignment = .center
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            collectionView.addSubview(emptyLabel)
            
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
            ])
        }
    }
    
    func showLoader(isShow: Bool) {
        if isShow {
            ProgressHUD.show()
        } else {
            ProgressHUD.dismiss()
        }
    }
}

extension NFTCollectionViewScreenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.nfts.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? NFTCollectionCell else {
            fatalError("Unable to dequeue StatNFTCell")
        }
        
        let nft = viewModel.nfts[indexPath.row]
        let inCart = viewModel.cartItemsIds.contains(nft.id)
        let isFavorite = viewModel.likes.contains(nft.id)

        cell.configure(with: nft, inCart: inCart, isFavorite: isFavorite)
        cell.delegate = self

        return cell
    }
    
}

extension NFTCollectionViewScreenViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 16 - 16 - 16) / 3, height: 192)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 20
    }
}

extension NFTCollectionViewScreenViewController: CollectionCellDelegate {
    func addToCart(id: String) {
        UIProgressHUD.show()
        
        let ids = viewModel.cartItemsIds + [id]
        
        cartManager.addNFTFromStatistics(id: "1", nfts: ids) { result in
            switch result {
            case .success(let order):
                UIProgressHUD.dismiss()
                self.viewModel.fetchCart { [weak self] active in
                    self?.showLoader(isShow: active)
                }
                print("\(order.id) successfully added")
            case .failure(let error):
                UIProgressHUD.dismiss()
                print("\(error.localizedDescription) couldn't add NFT")
            }
        }
        
    }
    
    func removeFromCart(id: String) {
        UIProgressHUD.show()
        
        let ids = viewModel.cartItemsIds.filter { $0 != id }

        cartManager.removeNFTFromCart(id: "1", nfts: ids) { result in
            switch result {
            case .success(let order):
                UIProgressHUD.dismiss()
                
                self.viewModel.fetchCart { [weak self] active in
                    self?.showLoader(isShow: active)
                }
                
                print("\(order.id) successfully removed")
            case .failure(let error):
                UIProgressHUD.dismiss()
                print("\(error.localizedDescription) couldn't add NFT")
            }
        }
        
    }
    
    func toggleLike(id: String) {
        UIProgressHUD.show()

        var likes: [String] = []
        
        if viewModel.likes.contains(id) {
            likes = viewModel.likes.filter { $0 != id }
        } else {
            likes = viewModel.likes + [id]
        }
        
        viewModel.toggleLikes(likes: likes) { _ in
            UIProgressHUD.dismiss()
        }
        
    }
}
