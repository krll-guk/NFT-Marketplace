import UIKit
import Kingfisher

protocol NFTCollectionViewCellDelegate: AnyObject {
    func didTapCart(in cell: NFTCollectionViewCell)
    func didTapLike(in cell: NFTCollectionViewCell)
}

final class NFTCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
    
    // MARK: Internal properties
    
    weak var delegate: NFTCollectionViewCellDelegate?
    
    var nftModel: NFTModel? {
        didSet {
            guard let nftModel = nftModel else {
                return
            }
            nftImage.kf.indicatorType = .activity
            nftImage.kf.setImage(with: URL(string: nftModel.imageLink.percentEncoded))
            
            fillRatingStack(value: nftModel.rating)
            nameLabel.text = nftModel.name
            priceLabel.text = "\(nftModel.price) ETH"
        }
    }
    
    var orderModel: OrderModel? {
        didSet {
            guard let nftModel = nftModel else {
                return
            }
            let isInCart = orderModel?.inCartNFTIDs.contains(nftModel.id) ?? false
            cartButton.setImage(isInCart ? .NFTCard.inCart : .NFTCard.notInCart, for: .normal)
        }
    }
    
    var profileModel: ProfileModel? {
        didSet {
            guard let nftModel = nftModel else {
                return
            }
            let isLiked = profileModel?.likedNFTIDs.contains(nftModel.id) ?? false
            favoriteButton.tintColor = isLiked ? .Universal.red : .Universal.white
            favoriteButton.setImage(.NFTCard.heart, for: .normal)
        }
    }
    
    // MARK: Private properties
    
    private let nftImage: UIImageView = {
        let image = UIImageView()
        
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 12
        
        image.widthAnchor.constraint(equalTo: image.heightAnchor).isActive = true
        return image
    }()
    
    private let ratingStack: UIStackView = {
        let stack = UIStackView()
        
        stack.axis = .horizontal
        stack.spacing = 2
        
        return stack
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .Themed.black
        label.font = .Bold.size17
        
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .Themed.black
        label.font = .Medium.size10
        
        return label
    }()
    
    private lazy var cartButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        
        button.addTarget(self, action: #selector(didTapCartButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        
        button.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override functions
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nftImage.kf.cancelDownloadTask()
        ratingStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    // MARK: Private functions
    
    @objc
    private func didTapCartButton() {
        delegate?.didTapCart(in: self)
    }
    
    @objc
    private func didTapFavoriteButton() {
        delegate?.didTapLike(in: self)
    }
    
    private func fillRatingStack(value: Int) {
        for index in 1...5 {
            let imageView = UIImageView()
            
            if index <= value {
                imageView.image = .NFTCard.star?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = .Universal.yellow
            } else {
                imageView.image = .NFTCard.star?.withRenderingMode(.alwaysOriginal)
            }
            ratingStack.addArrangedSubview(imageView)
        }
        ratingStack.addArrangedSubview(UIView())
    }
    
    private func makeViewLayout() {
        let labelCartStack = makeLabelCartStack()
        
        contentView.addSubview(nftImage)
        contentView.addSubview(ratingStack)
        contentView.addSubview(labelCartStack)
        contentView.addSubview(favoriteButton)
        
        nftImage.translatesAutoresizingMaskIntoConstraints = false
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        labelCartStack.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nftImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            ratingStack.topAnchor.constraint(equalTo: nftImage.bottomAnchor, constant: 8),
            ratingStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            labelCartStack.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 4),
            labelCartStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            labelCartStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    private func makeLabelCartStack() -> UIStackView {
        let labelStack = UIStackView()
        labelStack.axis = .vertical
        
        labelStack.addArrangedSubview(nameLabel)
        labelStack.addArrangedSubview(priceLabel)
        
        let cartStack = UIStackView()
        cartStack.axis = .horizontal
        
        cartStack.addArrangedSubview(labelStack)
        cartStack.addArrangedSubview(cartButton)
        
        return cartStack
    }
}
