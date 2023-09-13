//
//  NFTCollectionCell.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 31.08.2023.
//

import UIKit
import Kingfisher
import SwiftUI

final class NFTCollectionCell: UICollectionViewCell {
    private var currentNFT: Nft?
    private var inCart: Bool = false
    private var isFavorite: Bool = false
    weak var delegate: CollectionCellDelegate?
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.Themed.lightGray
        button.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cartButton: UIButton = {
        let button = UIButton()

        button.addTarget(self, action: #selector(cartButtonPressed), for: .touchUpInside)
        button.tintColor = UIColor.Themed.black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var imageBackground: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.backgroundColor = UIColor.Themed.white
        return view
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.Themed.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.Themed.black
        label.font = UIFont.Medium.size10
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: nil, inCart: false, isFavorite: false)
    }
    
    let ratingView = RatingStackView()
}

extension NFTCollectionCell {
    func configure(with nft: Nft?, inCart: Bool, isFavorite: Bool) {
        self.currentNFT = nft
        self.inCart = inCart
        self.isFavorite = isFavorite

        cartButton.setImage(inCart ? UIImage.NFTCard.remove_cart : UIImage.NFTCard.add_cart, for: .normal)
        likeButton.setImage(isFavorite ? UIImage.NFTCard.heart_filled : UIImage.NFTCard.heart, for: .normal)

        nameLabel.text = nft?.name
        nameLabel.font = UIFont.Bold.size17
        ratingView.setupRating(rating: nft?.rating ?? 0)

        if let price = nft?.price {
            priceLabel.text = String(price) + " ETH"
        } else {
            priceLabel.text = "?"
        }
        
        guard let url = nft?.images[0], let validUrl = URL(string: url) else {return}
        let processor = RoundCornerImageProcessor(cornerRadius: 12)
        let options: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .cacheOriginalImage
        ]
        imageBackground.kf.setImage(with: validUrl, options: options)
    }
}

private extension NFTCollectionCell {
    @objc
    func likeTapped() {
        guard let id = self.currentNFT?.id else { return }
        
        delegate?.toggleLike(id: id)
    }
    
    @objc func cartButtonPressed() {
        guard let id = self.currentNFT?.id else { return }
        
        if inCart {
            self.delegate?.removeFromCart(id: id)
        } else {
            self.delegate?.addToCart(id: id)
        }
    }
}

private extension NFTCollectionCell {
    func setupAppearance() {
        contentView.addSubview(imageBackground)
        contentView.addSubview(ratingView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(cartButton)
        contentView.addSubview(priceLabel)
        contentView.addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            imageBackground.topAnchor.constraint(equalTo: topAnchor),
            imageBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageBackground.heightAnchor.constraint(equalTo: widthAnchor),
            
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),
            likeButton.topAnchor.constraint(equalTo: imageBackground.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: imageBackground.trailingAnchor),
            
            ratingView.topAnchor.constraint(equalTo: imageBackground.bottomAnchor, constant: 8),
            ratingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingView.heightAnchor.constraint(equalToConstant: 12),
            
            nameLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40),
            cartButton.bottomAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 0),
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            priceLabel.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
}
