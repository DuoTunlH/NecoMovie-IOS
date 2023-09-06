//
//  AppTextField.swift
//  NetfilxClone
//
//  Created by tungdd on 31/08/2023.
//

import UIKit

class AppTextField: UITextField {
    override var placeholder: String? {
        get {
            attributedPlaceholder?.string
        }
        set {
            attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
       
    func setupUI() {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        leftViewMode = .always
        layer.cornerRadius = 8
    }
}

