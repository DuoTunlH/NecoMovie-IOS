//
//  CollectionViewCell.swift
//  NetfilxClone
//
//  Created by tungdd on 26/06/2023.
//

import UIKit
import SDWebImage

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.layer.cornerRadius = 10.0
        
    }
    
    func configure(with url: String) {
            let url = URL(string: "https://image.tmdb.org/t/p/w500/\(url)")
            posterImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
    }
}
