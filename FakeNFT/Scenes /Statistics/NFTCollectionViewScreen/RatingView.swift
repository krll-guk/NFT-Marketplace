//
//  RatingView.swift
//  FakeNFT
//
//  Created by Igor Ignatov on 10.09.2023.
//

import UIKit

final class RatingStackView: UIStackView {
    private let starImage: UIImage? = UIImage.NFTCard.star
    
    init(rating: Int = 5) {
        super.init(frame: .zero)
        axis = .horizontal
        spacing = 2
        translatesAutoresizingMaskIntoConstraints = false
        
        (1...rating).forEach {
            let imageView = UIImageView()
            imageView.image = starImage
            imageView.tintColor = UIColor.Universal.yellow
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
                imageView.image = starImage
                imageView.tintColor = imageView.tag > rating ? UIColor.Themed.lightGray : UIColor.Universal.yellow
            }
        }
    }
}
