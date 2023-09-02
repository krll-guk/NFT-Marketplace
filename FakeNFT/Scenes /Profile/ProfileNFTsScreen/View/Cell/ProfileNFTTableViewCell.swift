import UIKit
import Kingfisher

final class ProfileNFTTableViewCell: UITableViewCell, ReuseIdentifying {

    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .Themed.lightGray
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 12
        image.clipsToBounds = true
        return image
    }()

    private lazy var heart: UIImageView = {
        let image = UIImageView()
        image.image = .NFTCard.heart
        return image
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
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let ratingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        return stack
    }()

    private let autorStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .firstBaseline
        return stack
    }()

    private lazy var from: UILabel = {
        let label = UILabel()
        label.font = .Regular.size15
        label.textColor = .Themed.black
        label.text = .ProfileNFTTableViewCell.from
        return label
    }()

    private lazy var author: UILabel = {
        let label = UILabel()
        label.font = .Regular.size13
        label.textColor = .Themed.black
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let priceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()

    private lazy var price: UILabel = {
        let label = UILabel()
        label.font = .Regular.size13
        label.textColor = .Themed.black
        label.text = .ProfileNFTTableViewCell.price
        return label
    }()

    private lazy var priceNFT: UILabel = {
        let label = UILabel()
        label.font = .Bold.size17
        label.textColor = .Themed.black
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    var cellViewModel: ProfileNFTCellViewModel? {
        didSet {
            guard let cellViewModel = cellViewModel else { return }
            image.kf.indicatorType = .activity
            image.kf.setImage(with: cellViewModel.url)
            heart.tintColor = cellViewModel.isLiked ? .Universal.red : .Universal.white
            name.text = cellViewModel.name
            addRating(cellViewModel.rating)
            author.text = cellViewModel.author
            priceNFT.text = cellViewModel.price + .ProfileNFTTableViewCell.currency
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        author.text = ""
        priceNFT.text = ""
    }

    private func setupContentView() {
        selectionStyle = .none
        backgroundColor = .Themed.white

        [image, heart, nameStack, priceStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [name, ratingStack, autorStack].forEach {
            nameStack.addArrangedSubview($0)
        }

        [from, author].forEach {
            autorStack.addArrangedSubview($0)
        }

        [price, priceNFT].forEach {
            priceStack.addArrangedSubview($0)
        }

        setConstraints()
        fillStack()
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            // image
            image.heightAnchor.constraint(equalToConstant: 108),
            image.widthAnchor.constraint(equalToConstant: 108),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            // heart
            heart.topAnchor.constraint(equalTo: image.topAnchor),
            heart.trailingAnchor.constraint(equalTo: image.trailingAnchor),

            // nameStack
            nameStack.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20),
            nameStack.trailingAnchor.constraint(lessThanOrEqualTo: priceStack.leadingAnchor, constant: -20),

            // ratingStack
            ratingStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // priceStack
            priceStack.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 137),
            priceStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
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
        for index in 0...rating-1 {
            self.ratingStack.arrangedSubviews[index].tintColor = .Universal.yellow
        }
    }
}
