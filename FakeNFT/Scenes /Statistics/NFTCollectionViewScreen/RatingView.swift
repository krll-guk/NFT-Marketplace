//
//  RatingView.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 10.09.2023.
//

import UIKit

final class RatingStackView: UIStackView {
    private let fillStarImage: UIImage? = UIImage.NFTCard.star_filled
    private let emptyStarImage: UIImage? = UIImage.NFTCard.star
    
    init(rating: Int = 5) {
        super.init(frame: .zero)
        axis = .horizontal
        spacing = 2
        translatesAutoresizingMaskIntoConstraints = false
        
        (1...rating).forEach {
            let imageView = UIImageView()
            imageView.image = emptyStarImage
            imageView.tintColor = UIColor.Universal.gray
            imageView.tag = $0
            addArrangedSubview(imageView)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRating(rating: Int) {
        subviews.forEach {
            if let imageView = $0 as? UIImageView {
                imageView.image = imageView.tag > rating ? emptyStarImage : fillStarImage
            }
        }
    }
}
