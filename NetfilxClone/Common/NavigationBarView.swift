//
//  HomeNavigationBarViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 26/06/2023.
//

import UIKit
import FirebaseAuth
import SDWebImage
import Combine

protocol NavigationBarDelegate: AnyObject {
    func leftBtnDidTap()
    func rightBtn1DidTap()
}

class NavigationBarView: UIView {

    @IBOutlet weak var rightBtn1: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var rightBtn2: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    weak var delegate: NavigationBarDelegate?
    var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        Bundle.main.loadNibNamed("NavigationBarView", owner: self)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        rightBtn1.tintColor = .white
        rightBtn2.tintColor = .white
        
        if let url = Auth.auth().currentUser?.photoURL {
            rightBtn1.sd_setBackgroundImage(with: url, for: .normal)
            rightBtn1.setImage(UIImage(), for: .normal)
            rightBtn1.layer.masksToBounds = true
            rightBtn1.layer.cornerRadius = (rightBtn1.layer.bounds.width) / 2
            rightBtn1.layer.borderColor = UIColor.white.cgColor
            rightBtn1.layer.borderWidth = 0.5
        }
        
        let changeAvatar = Notification.Name("changeAvatar")
        
        NotificationCenter.default
            .publisher(for: changeAvatar, object: nil)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] notification in
                self?.rightBtn1.setBackgroundImage(notification.object as? UIImage, for: .normal)
            }.store(in: &cancellables)
    }

    @IBAction func rightBtn1DidTap(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.rightBtn1DidTap()
        }
    }
    
    @IBAction func leftBtnDidTap(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.leftBtnDidTap()
        }
    }
}
