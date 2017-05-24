//
//  SelectCornerRadiusView.swift
//  Phonics
//
//  Created by Cal Stephens on 1/14/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

@IBDesignable
class SelectCornerRadiusView : UIView {
    
    @IBInspectable var topLeft: Bool = true
    @IBInspectable var topRight: Bool = true
    @IBInspectable var bottomLeft: Bool = true
    @IBInspectable var bottomRight: Bool = true
    
    @IBInspectable var cornerRadius: Double = -1
    
    @IBInspectable var borderColor: UIColor = .clear
    @IBInspectable var borderThickness: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        let mask = CAShapeLayer()
        let radius = CGSize(width: CGFloat(cornerRadius), height: CGFloat(cornerRadius))
        var corners: UIRectCorner = []
        
        if topLeft { corners.formSymmetricDifference(.topLeft) }
        if topRight { corners.formSymmetricDifference(.topRight) }
        if bottomLeft { corners.formSymmetricDifference(.bottomLeft) }
        if bottomRight { corners.formSymmetricDifference(.bottomRight) }
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radius)
        mask.path = path.cgPath
        self.layer.mask = mask
        
        //add custom border view
        if self.borderColor != .clear && self.borderThickness != 0 {
            let frameLayer = CAShapeLayer()
            frameLayer.frame = self.bounds
            frameLayer.path = path.cgPath
            frameLayer.strokeColor = self.borderColor.cgColor
            frameLayer.lineWidth = self.borderThickness
            frameLayer.fillColor = nil
            
            self.layer.addSublayer(frameLayer)
        }
    }
    
}

@IBDesignable
class CornerRadiusView : UIView {
    
    @IBInspectable var cornerRadius: Double = -1 {
        didSet {
            if cornerRadius == -1 {
                self.layer.cornerRadius = self.frame.width / 2
            } else {
                self.layer.cornerRadius = CGFloat(cornerRadius)
            }
        }
    }
    
}
