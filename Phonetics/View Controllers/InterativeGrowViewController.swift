//
//  InterativeGrowViewController.swift
//  Phonetics
//
//  Created by Cal on 7/3/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit


///This class is configured through Interface Builder. 
/// (1) Create a subclass of this class
/// (2) Wire Controller -> View and add the views to `interactiveViews`
/// (3) Create a `UITouchGestureRecognizer` and point it to `gestureRecognized`
/// (3) Create a `UIPanGestureRecognizer` and point it to `gestureRecognized`
/// (4) In your subclass, implement the customization points
class InteractiveGrowViewController : UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var interactiveViews: [UIView]!
    private var selectedViews = [UIView]()
    
    @IBAction func gestureRecognized(sender: UIGestureRecognizer) {
        for view in interactiveViews {
            if !interactiveGrowShouldHappenFor(view) { continue }
            
            let location = sender.locationInView(view)
            var selected = CGRectContainsPoint(view.bounds, location)
            
            if sender.state == .Ended {
                selected = false
            }
            
            setView(view, selected: selected)
        }
    }
    
    private func setView(view: UIView, selected: Bool) {
        
        if (selected) {
            if selectedViews.contains(view) { return }
            else {
                selectedViews.append(view)
                interactiveGrowActionFor(view)
            }
        } else {
            if !selectedViews.contains(view) { return }
            else { selectedViews.removeAtIndex(selectedViews.indexOf(view)!) }
        }
        
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.AllowUserInteraction], animations: {
                                    
            let scale = selected ? self.interactiveGrowScaleFor(view) : 1.0
            view.transform = CGAffineTransformMakeScale(scale, scale)
                                    
        }, completion: nil)
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    //MARK: - Customization Points
    
    func interactiveGrowScaleFor(view: UIView) -> CGFloat {
        return 1.2
    }
    
    func interactiveGrowActionFor(view: UIView) {
        return
    }
    
    func interactiveGrowShouldHappenFor(view: UIView) -> Bool {
        return true
    }
    
    
    
}