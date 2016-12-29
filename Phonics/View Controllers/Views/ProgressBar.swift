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
            reloadFillView()
        }
    }
    
    @IBInspectable var numberOfFilledSegments: Int = 2 {
        didSet {
            reloadFillView()
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
    
    private var fillView: UIView!
    
    
    //MARK: - Configure view
    
    override func prepareForInterfaceBuilder() {
        self.reloadFillView()
    }
    
    private func reloadFillView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if fillView == nil {
            fillView = UIView()
            fillView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(fillView)
            
            fillView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            fillView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            fillView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
        //remove old width constraints
        self.constraints.forEach { constraint in
            if constraint.firstAttribute == .width
                && (constraint.firstItem as? UIView == fillView
                    || constraint.secondItem as? UIView == fillView) {
                
                self.removeConstraint(constraint)
            }
        }
        
        //add new constraint
        var widthRatio = CGFloat(self.numberOfFilledSegments) / CGFloat(max(1, self.totalNumberOfSegments))
        
        if widthRatio == 0.0 {
            widthRatio = 1.0
            self.fillView.alpha = 0.0
        } else {
            self.fillView.alpha = 1.0
        }
        
        fillView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: widthRatio).isActive = true
        
        updateColors()
        self.fillView.layoutIfNeeded()
    }
    
    private func updateColors() {
        self.backgroundColor = self.emptyColor
        self.fillView.backgroundColor = self.fillColor
    }
    
}
