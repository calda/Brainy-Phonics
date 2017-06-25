//
//  LabelView.swift
//  Phonics
//
//  Created by Cal Stephens on 6/24/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

class BasicLabelView: UIView {
    
    private let label: UILabel
    
    init(with text: String, font: UIFont) {
        label = UILabel()
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        setUpLabel(with: text, font: font)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private func setUpLabel(with text: String, font: UIFont) {
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constraintInCenterOfSuperview()
        label.text = text.replacingOccurrences(of: "_", with: "    ")
        label.font = font
    }
    
}

extension UIView {
    
    func constraintInCenterOfSuperview(requireHugging: Bool = true) {
        guard let superview = superview else {
            return
        }
        
        self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        self.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor).isActive = true
        self.topAnchor.constraint(greaterThanOrEqualTo: superview.topAnchor).isActive = true
        self.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor).isActive = true
        
        if requireHugging {
            self.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
            self.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        }
    }
    
}
