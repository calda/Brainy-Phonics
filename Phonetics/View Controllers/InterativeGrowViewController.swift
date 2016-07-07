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
/// (3) In your subclass, implement the customization points
class InteractiveGrowViewController : UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var interactiveViews: [UIView]!
    private var selectedViews = [UIView : SelectionState]()
    
    private enum SelectionState {
        case Growing(NSDate), Grown
        
        var startTime: NSDate? {
            switch (self) {
                case .Growing(let date): return date
                default: return nil
            }
        }
        
        var isGrowing: Bool {
            switch (self) {
                case .Growing(_): return true
                default: return false
            }
        }
    }
    
    
    //MARK: - Touch Recognizing
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchRecognized(touch, state: .Began)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchRecognized(touch, state: .Changed)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchRecognized(touch, state: .Ended)
    }
    
    private func touchRecognized(touch: UITouch, state: UIGestureRecognizerState) {
        for view in interactiveViews {
            if !interactiveGrowShouldHappenFor(view) { continue }
            
            let selected: Bool
        
            if state == .Ended {
                selected = false
            } else {
                let location = touch.locationInView(view)
                selected = CGRectContainsPoint(view.bounds, location)
            }
            
            (selected ? touchEnteredView : touchExitedView)(view, withState: state)
        }
    }
    
    
    //MARK: - View Selection
    
    private func touchEnteredView(view: UIView, withState state: UIGestureRecognizerState) {
        
        if !selectedViews.keys.contains(view) {
            selectedViews[view] = .Growing(NSDate())
            self.interactiveViewWilGrow(view)
            
            self.animateBlock({
                
                    let scale = self.interactiveGrowScaleFor(view)
                    view.transform = CGAffineTransformMakeScale(scale, scale)
                
                }, withCompletion: { completed in
                    
                    if self.selectedViews.keys.contains(view) {
                        self.interactiveViewDidGrow(view)
                        self.selectedViews[view] = .Grown
                    }
                    
                }, forInteractiveView: view)
            
        }
        
    }
    
    private func touchExitedView(view: UIView, withState state: UIGestureRecognizerState) {
        
        if selectedViews.keys.contains(view) {
            
            if state == .Ended {
                self.touchUpForInteractiveView(view)
            }
            
            if selectedViews[view]!.isGrowing {
                if let duration = totalDurationForInterruptedAnimationOn(view) {
                    continueAnimationOnView(view, forTotalDuration: duration)
                    return
                } else {
                    view.layer.removeAllAnimations()
                }
            }
            
            selectedViews.removeValueForKey(view)
        
            self.animateBlock({
                view.transform = CGAffineTransformIdentity
            }, withCompletion: nil, forInteractiveView: view)
        }
        
    }
    
    private func continueAnimationOnView(view: UIView, forTotalDuration duration: NSTimeInterval) {
        guard let startTime = selectedViews[view]?.startTime else { return }
        let timeSinceStart = NSDate().timeIntervalSinceDate(startTime)
        let timeRemaining = max(0, duration - timeSinceStart)
        
        weak var weakView = view
        weak var weakSelf = self
        
        delay(timeRemaining) {
            if let strongView = weakView, let strongSelf = weakSelf {
                self.animateBlock({
                        view.transform = CGAffineTransformIdentity
                    }, withCompletion: { _ in
                        strongSelf.selectedViews.removeValueForKey(strongView)
                    }, forInteractiveView: strongView)
            }
        }
    }
    
    
    //MARK: - Customization Points
    
    ///There has been a touch over the view. What scale should the view grow to, at this time?
    func interactiveGrowScaleFor(view: UIView) -> CGFloat {
        return 1.2
    }
    
    ///There has been a touch over the view. Should the view grow, at this time?
    func interactiveGrowShouldHappenFor(view: UIView) -> Bool {
        return true
    }
    
    ///The view is about to start growing
    func interactiveViewWilGrow(view: UIView) {
        return
    }
    
    ///The view finished growing
    func interactiveViewDidGrow(view: UIView) {
        return
    }
    
    ///The view recieved a Touch Up Inside event
    func touchUpForInteractiveView(view: UIView) {
        return
    }
    
    ///The tap exited the view before it could finish growing. How long should the view be grown for, from start to end?
    func totalDurationForInterruptedAnimationOn(view: UIView) -> NSTimeInterval? {
        return nil
    }
    
    ///The block and completion should be used in a UIView animation to achieve the desired grow animation.
    func animateBlock(block: () -> (), withCompletion completion: ((Bool) -> ())?, forInteractiveView view: UIView) {
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0,
                                   options: [.AllowUserInteraction], animations: block, completion: completion)
    }
    
    

}