//
//  HeaderCollectionReusableView.swift
//  NetfilxClone
//
//  Created by tungdd on 06/07/2023.
//

import UIKit
import WebKit

protocol MovieDetailHeaderDelagate: AnyObject {
    func favouriteBtnDidTap()
}

class MovieDetailHeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var videoWebView: WKWebView!
    @IBOutlet weak var favouriteButton: UIButton!
    weak var delegate: MovieDetailHeaderDelagate?
    
    var movieTrailers = [Video]()
    var isFavourite = false {
        didSet {
            changeToFavouriteView()
        }
    }
    var movie: Movie? {
        didSet {
            config()
        }
    }
    func config() {
        self.displayVideo()
        self.titleLabel.text = self.movie?.title ?? self.movie?.original_title
        self.descriptionLabel.text = self.movie?.overview
        descriptionLabel.font = UIFont.systemFont(ofSize: 17)
        if let date = self.movie?.release_date {
            if date != ""{
                let index = date.index(date.startIndex, offsetBy: 4)
                let substring = String(date.prefix(upTo: index))
                self.yearLabel.text = substring
            }
        }
    }
    
    @IBAction func favouriteBtnDidTap(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.favouriteBtnDidTap()
        }
    }
    
    func displayVideo() {
        for trailer in movieTrailers {
            if trailer.type == "Trailer" {
                let url = URL(string: "https://www.youtube.com/embed/\(trailer.key ?? "")")
                self.videoWebView.load(URLRequest(url: url!))
                break;
            }
        }
    }
    
    func changeToFavouriteView() {
        favouriteButton.setTitle(isFavourite ? " Remove from favourite" : " Add to favourite" , for: .normal)
        favouriteButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        favouriteButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            return outgoing
         }
        favouriteButton.setImage(UIImage(systemName: isFavourite ? "heart.fill" : "heart"), for: .normal)
    }
}
