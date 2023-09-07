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
    func profileBtnDidTap()
    func deleteBtnDidTap()
    func cancelBtnDidTap()
}

extension NavigationBarDelegate {
    func leftBtnDidTap() {
    }
    func deleteBtnDidTap() {
    }
    
    func cancelBtnDidTap() {
    }
}

class NavigationBarView: UIView {

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var notiBtn: UIButton!
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
        profileBtn.tintColor = .white
        notiBtn.tintColor = .white
        
        if let url = Auth.auth().currentUser?.photoURL {
            profileBtn.sd_setBackgroundImage(with: url, for: .normal)
            profileBtn.setImage(UIImage(), for: .normal)
            profileBtn.layer.masksToBounds = true
            profileBtn.layer.cornerRadius = (profileBtn.layer.bounds.width) / 2
            profileBtn.layer.borderColor = UIColor.white.cgColor
            profileBtn.layer.borderWidth = 0.5
        }
        
        let changeAvatar = Notification.Name("changeAvatar")
        
        NotificationCenter.default
            .publisher(for: changeAvatar, object: nil)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] notification in
                self?.profileBtn.setBackgroundImage(notification.object as? UIImage, for: .normal)
            }.store(in: &cancellables)
    }

    @IBAction func profileBtnDidTap(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.profileBtnDidTap()
        }
    }
    
    @IBAction func leftBtnDidTap(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.leftBtnDidTap()
        }
    }
    @IBAction func cancelBtnDidTap(_ sender: Any) {
        if let delegate = delegate {
            delegate.cancelBtnDidTap()
        }
    }
    @IBAction func deleteBtnDidTap(_ sender: Any) {
        if let delegate = delegate {
            delegate.deleteBtnDidTap()
        }
    }
}
