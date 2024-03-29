//
//  UpcomingTableViewCell.swift
//  NetfilxClone
//
//  Created by tungdd on 29/06/2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playImage.tintColor = #colorLiteral(red: 0.4686928988, green: 0.01086951792, blue: 0.8312569261, alpha: 1)
        posterImageView.layer.cornerRadius = 8.0
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(movie: Movie) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(movie.poster_path ?? "")") else {
            return
        }
        posterImageView.sd_setImage(with: url)
        titleLabel.text = movie.title ?? movie.original_title
    }
}
