import UIKit
import Kingfisher

protocol ProfileFavoriteNFTCollectionViewCellDelegate: ProfileFavoriteNFTViewController {
    func heartTapped(_ cell: ProfileFavoriteNFTCollectionViewCell)
}

final class ProfileFavoriteNFTCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
    weak var delegate: ProfileFavoriteNFTCollectionViewCellDelegate?

    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .Themed.lightGray
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 12
        image.clipsToBounds = true
        return image
    }()

    private lazy var heart: UIButton = {
        let button = UIButton()
        button.setImage(.NFTCard.heart, for: .normal)
        button.imageView?.contentMode = .center
        button.tintColor = .Universal.red
        button.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)
        return button
    }()

    private let nameStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    private lazy var name: UILabel = {
        let label = UILabel()
        label.font = .Bold.size17
        label.textColor = .Themed.black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let ratingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        return stack
    }()

    private lazy var priceNFT: UILabel = {
        let label = UILabel()
        label.font = .Regular.size15
        label.textColor = .Themed.black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    var cellViewModel: ProfileFavoriteNFTCellViewModel? {
        didSet {
            guard let cellViewModel = cellViewModel else { return }
            image.kf.indicatorType = .activity
            image.kf.setImage(with: cellViewModel.url)
            name.text = cellViewModel.name
            addRating(cellViewModel.rating)
            priceNFT.text = cellViewModel.price + .ProfileNFTTableViewCell.currency
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        image.kf.cancelDownloadTask()
        image.image = nil
        name.text = ""
        ratingStack.arrangedSubviews.forEach { $0.tintColor = .Themed.lightGray }
        priceNFT.text = ""
    }

    private func setupContentView() {
        backgroundColor = .clear

        [image, heart, nameStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [name, ratingStack, priceNFT].forEach {
            nameStack.addArrangedSubview($0)
        }

        nameStack.setCustomSpacing(8, after: ratingStack)
        setConstraints()
        fillStack()
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            // image
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            // heart
            heart.topAnchor.constraint(equalTo: image.topAnchor),
            heart.trailingAnchor.constraint(equalTo: image.trailingAnchor),
            heart.heightAnchor.constraint(equalToConstant: 29.63),
            heart.widthAnchor.constraint(equalToConstant: 29.63),

            // nameStack
            nameStack.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 12),
            nameStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // ratingStack
            ratingStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    private func fillStack() {
        for _ in 1...5 {
            let image = UIImageView()
            image.image = .NFTCard.star
            image.tintColor = .Themed.lightGray
            ratingStack.addArrangedSubview(image)
        }
    }

    private func addRating(_ rating: Int) {
        if rating != 0 {
            for index in 0...rating-1 {
                self.ratingStack.arrangedSubviews[index].tintColor = .Universal.yellow
            }
        }
    }

    @objc
    private func heartTapped() {
        delegate?.heartTapped(self)
    }
}
