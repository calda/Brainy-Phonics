//
//  ProgressBar.swift
//  Phonics
//
//  Created by Cal Stephens on 12/27/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressBar : UIView {
    
    @IBInspectable var totalNumberOfSegments: Int = 5 {
        didSet {
            reloadStackView()
        }
    }
    
    @IBInspectable var numberOfFilledSegments: Int = 2 {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable var spacing: CGFloat = 1 {
        didSet {
            stackView.spacing = spacing
        }
    }
    
    @IBInspectable var emptyColor: UIColor = .gray {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable var fillColor: UIColor = .red {
        didSet {
            updateColors()
        }
    }
    
    private var stackView: UIStackView!
    
    
    //MARK: - Configure view
    
    override func prepareForInterfaceBuilder() {
        self.reloadStackView()
    }
    
    private func reloadStackView() {
        if stackView == nil {
            stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.backgroundColor = .clear
            stackView.spacing = self.spacing
            self.addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        } else {
            stackView.arrangedSubviews.forEach(stackView.removeArrangedSubview)
        }
        
        for index in 0 ..< totalNumberOfSegments {
            let view = UIView()
            view.tag = index
            stackView.addArrangedSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        }
        
        updateColors()
        self.layoutIfNeeded()
    }
    
    private func updateColors() {
        for view in stackView.arrangedSubviews {
            let index = view.tag
            
            if index < numberOfFilledSegments {
                view.backgroundColor = self.fillColor
            } else {
                view.backgroundColor = self.emptyColor
            }
        }
    }
    
}
