//
//  PuzzleDetailViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 12/19/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class PuzzleDetailViewController : UIViewController {
    
    var puzzleView: PuzzleView!
    var puzzleViewOriginalFrame: CGRect!
    var puzzleViewOriginalSuperview: UIView!
    
    var sound: Sound!
    
    
    //MARK: - Presentation
    
    static func present(for sound: Sound, from puzzleView: PuzzleView, in source: UIViewController) {
        
        let puzzleDetail = PuzzleDetailViewController()
        puzzleDetail.puzzleView = puzzleView
        puzzleDetail.puzzleViewOriginalFrame = puzzleView.frame
        puzzleDetail.puzzleViewOriginalSuperview = puzzleView.superview
        puzzleDetail.sound = sound
        
        puzzleDetail.modalPresentationStyle = .overCurrentContext
        puzzleDetail.modalTransitionStyle = .coverVertical
        
        source.present(puzzleDetail, animated: false) { _ in
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = .clear
        
        //move puzzle view to this view controller
        let translatedFrame = self.view.convert(puzzleView.bounds, from: puzzleView)
        puzzleView.removeFromSuperview()
        NSLayoutConstraint.deactivate(puzzleView.constraints)
        self.view.addSubview(puzzleView)
        puzzleView.frame = translatedFrame
        
        //create constraints because otherwise the view refuses to behave normally
        func constrain(_ attribute: NSLayoutAttribute, to value: CGFloat, item: Any? = nil, attribute otherAttribute: NSLayoutAttribute = .notAnAttribute) -> NSLayoutConstraint {
            return NSLayoutConstraint(item: puzzleView, attribute: attribute, relatedBy: .equal, toItem: item, attribute: otherAttribute, multiplier: 1.0, constant: value)
        }
        
        let width = constrain(.width, to: puzzleView.frame.width)
        let height = constrain(.height, to: puzzleView.frame.height)
        let x = constrain(.left, to: puzzleView.frame.origin.x, item: self.view, attribute: .left)
        let y = constrain(.top, to: puzzleView.frame.origin.y, item: self.view, attribute: .top)
        
        self.view.addConstraints([width, height, x, y])
        
        //update constraints to center view
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.curveEaseIn], animations: {
            let newHeight = min(self.view.frame.height - 40, 600)
            let newWidth = newHeight * (3/4)
            
            let newX = self.view.frame.width / 2 - newWidth / 2
            let newY = self.view.frame.height / 2 - newHeight / 2
            
            height.constant = newHeight
            width.constant = newWidth
            x.constant = newX
            y.constant = newY
            
            self.puzzleView.spacing = 20.0
            self.puzzleView.layoutPieces(animate: true)
            
            self.puzzleView.frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        }, completion: nil)
        
    }
    
}
