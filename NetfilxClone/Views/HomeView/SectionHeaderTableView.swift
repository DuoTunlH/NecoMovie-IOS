//
//  SectionHeaderTableView.swift
//  NetfilxClone
//
//  Created by tungdd on 27/06/2023.
//

import UIKit
protocol SectionHeaderTableViewDelegate: AnyObject {
    func didTap(section: Sections)
}

class SectionHeaderTableView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    weak var delegate: SectionHeaderTableViewDelegate?
    var section: Sections?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        Bundle.main.loadNibNamed("SectionHeaderTableView", owner: self)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }
    
    func config() {
        headerTitle.textColor = .white
        headerTitle.text = section?.title
    }
    
    @IBAction func seeAllDidTap(_ sender: Any) {
        if let delegate {
            delegate.didTap(section: section!)
        }
    }
}
