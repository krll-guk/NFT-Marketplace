import UIKit

final class NFTCatalogTableViewCell: UITableViewCell, ReuseIdentifying {
    
    private let coverImage: UIImageView = {
        let image = UIImageView()
        
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 12
        
        image.heightAnchor.constraint(equalToConstant: 140).isActive = true
        return image
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .Themed.black
        label.font = .Bold.size17
        
        return label
    }()
    
    // MARK: Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal functions
    
    func configure(cover: UIImage?, caption: String) {
        coverImage.image = cover
        captionLabel.text = caption
    }
    
    // MARK: Private functions
    
    private func makeViewLayout() {
        contentView.heightAnchor.constraint(equalToConstant: 187).isActive = true
        
        contentView.addSubview(coverImage)
        contentView.addSubview(captionLabel)
        
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            coverImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coverImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            captionLabel.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: 4),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        ])
    }
}
