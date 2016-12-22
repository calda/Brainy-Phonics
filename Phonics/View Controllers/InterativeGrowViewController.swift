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
        case growing(Date), grown
        
        var startTime: Date? {
            switch (self) {
                case .growing(let date): return date
                default: return nil
            }
        }
        
        var isGrowing: Bool {
            switch (self) {
                case .growing(_): return true
                default: return false
            }
        }
    }
    
    
    //MARK: - Touch Recognizing
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchRecognized(touch, state: .began)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchRecognized(touch, state: .changed)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchRecognized(touch, state: .ended)
    }
    
    fileprivate func touchRecognized(_ touch: UITouch, state: UIGestureRecognizerState) {
        if !self.view.isUserInteractionEnabled { return }
        
        for view in interactiveViews {
            if !interactiveGrowShouldHappenFor(view) { continue }
            
            let selected: Bool
        
            if state == .ended {
                selected = false
            } else {
                let location = touch.location(in: view)
                selected = view.bounds.contains(location)
            }
            
            (selected ? touchEnteredView : touchExitedView)(view, state)
        }
    }
    
    
    //MARK: - View Selection
    
    fileprivate func touchEnteredView(_ view: UIView, withState state: UIGestureRecognizerState) {
        
        if !selectedViews.keys.contains(view) {
            selectedViews[view] = .growing(Date())
            self.interactiveViewWilGrow(view)
            
            self.animateBlock({
                
                    let scale = self.interactiveGrowScaleFor(view)
                    view.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                }, withCompletion: { completed in
                    
                    if self.selectedViews.keys.contains(view) {
                        self.interactiveViewDidGrow(view)
                        self.selectedViews[view] = .grown
                    }
                    
                }, forInteractiveView: view)
            
        }
        
    }
    
    fileprivate func touchExitedView(_ view: UIView, withState state: UIGestureRecognizerState) {
        
        if selectedViews.keys.contains(view) {
            
            if state == .ended {
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
            
            selectedViews.removeValue(forKey: view)
        
            if self.shouldAnimateShrinkForInteractiveView(view, isTouchUp: state == .ended) {
                self.animateBlock({
                    view.transform = CGAffineTransform.identity
                }, withCompletion: nil, forInteractiveView: view)
            }
            
        }
        
    }
    
    fileprivate func continueAnimationOnView(_ view: UIView, forTotalDuration duration: TimeInterval) {
        guard let startTime = selectedViews[view]?.startTime else { return }
        let timeSinceStart = Date().timeIntervalSince(startTime)
        let timeRemaining = max(0, duration - timeSinceStart)
        
        weak var weakView = view
        weak var weakSelf = self
        
        delay(timeRemaining) {
            if let strongView = weakView, let strongSelf = weakSelf {
                self.animateBlock({
                        view.transform = CGAffineTransform.identity
                    }, withCompletion: { _ in
                        strongSelf.selectedViews.removeValue(forKey: strongView)
                    }, forInteractiveView: strongView)
            }
        }
    }
    
    
    //MARK: - Customization Points
    
    ///There has been a touch over the view. What scale should the view grow to?
    func interactiveGrowScaleFor(_ view: UIView) -> CGFloat {
        return 1.2
    }
    
    ///There has been a touch over the view. Should the view grow?
    func interactiveGrowShouldHappenFor(_ view: UIView) -> Bool {
        return true
    }
    
    ///The view is about to start growing
    func interactiveViewWilGrow(_ view: UIView) {
        return
    }
    
    ///The view finished growing
    func interactiveViewDidGrow(_ view: UIView) {
        return
    }
    
    //Should the view play a shrink animation?
    func shouldAnimateShrinkForInteractiveView(_ view: UIView, isTouchUp: Bool) -> Bool {
        return true
    }
    
    ///The view recieved a Touch Up Inside event
    func touchUpForInteractiveView(_ view: UIView) {
        return
    }
    
    ///The tap exited the view before it could finish growing. How long should the view be grown for, from start to end?
    func totalDurationForInterruptedAnimationOn(_ view: UIView) -> TimeInterval? {
        return nil
    }
    
    ///The block and completion should be used in a UIView animation to achieve the desired grow animation.
    func animateBlock(_ block: @escaping () -> (), withCompletion completion: ((Bool) -> ())?, forInteractiveView view: UIView) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0,
                                   options: [.allowUserInteraction], animations: block, completion: completion)
    }
    
    

}
