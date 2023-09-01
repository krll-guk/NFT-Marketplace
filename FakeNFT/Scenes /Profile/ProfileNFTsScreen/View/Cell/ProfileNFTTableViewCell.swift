import UIKit

final class ProfileNFTTableViewCell: UITableViewCell, ReuseIdentifying {
    
    var cellViewModel: ProfileNFTCellViewModel? {
        didSet {
            textLabel?.text = (cellViewModel?.name ?? "") + (cellViewModel?.price ?? "")
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = ""
    }
}
