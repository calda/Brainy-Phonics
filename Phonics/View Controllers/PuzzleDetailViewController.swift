//
//  PuzzleDetailViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 12/19/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class PuzzleDetailViewController : UIViewController {
    
    var oldPuzzleView: PuzzleView!
    var sound: Sound!
    var animator: Animator?
    
    
    //MARK: - Presentation
    
    static func present(for sound: Sound, from puzzleView: PuzzleView, in source: UIViewController) {
        
        let puzzleDetail = PuzzleDetailViewController()
        puzzleDetail.oldPuzzleView = puzzleView
        puzzleDetail.sound = sound
        
        puzzleDetail.modalPresentationStyle = .overCurrentContext
        puzzleDetail.modalTransitionStyle = .coverVertical
        
        source.present(puzzleDetail, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = .clear
        
        //create new puzzle view
        guard let oldPuzzleView = self.oldPuzzleView else { return }
        let translatedFrame = self.view.convert(oldPuzzleView.bounds, from: oldPuzzleView)
        
        let newPuzzleView = PuzzleView(frame: translatedFrame)
        newPuzzleView.puzzleName = oldPuzzleView.puzzleName
        newPuzzleView.spacing = oldPuzzleView.spacing
        newPuzzleView.puzzleName = oldPuzzleView.puzzleName
        
        oldPuzzleView.alpha = 0.0
        self.view.addSubview(newPuzzleView)
        
        //manually animate this puzzle because UIView.animate isn't cutting it
        
        //animate to center
        //UIView.animate(withDuration: 10.0) {
        let newHeight = self.view.frame.height * 0.9
        let puzzleRatio = newPuzzleView.frame.width / newPuzzleView.frame.height
        let newWidth = puzzleRatio * newHeight
    
        let newX = self.view.frame.width / 2 - newWidth / 2
        let newY = self.view.frame.height / 2 - newHeight / 2
        
        let newFrame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        self.animator = Animator(view: newPuzzleView, animateTo: newFrame, duration: 0.6)
        //}
        
        
    }
    
    
    //MARK: - Animator
    
    @objc class Animator : NSObject {
        
        let view: UIView
        let startFrame: CGRect
        let endFrame: CGRect
        let duration: TimeInterval
        let startTime: Date
        
        var timer: Timer!
        
        init(view: UIView, animateTo endFrame: CGRect, duration: TimeInterval) {
            self.view = view
            self.startFrame = view.frame
            self.endFrame = endFrame
            self.duration = duration
            self.startTime = Date()
            
            self.timer = nil
            super.init()
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.00001, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
        
        @objc func update() {
            let timeElapsed = Date().timeIntervalSince(startTime)
            let uncurvedPercentage = min(timeElapsed / duration, 1.0)
            
            if uncurvedPercentage >= 1.0 {
                self.timer.invalidate()
            }
            
            //ease-in ease-out curve
            let t = CGFloat(uncurvedPercentage)
            let animationPercentage = pow(t,2) / (2 * (pow(t,2) - t) + 1)
            
            func interpolate(start: CGFloat, end: CGFloat) -> CGFloat {
                let difference = end - start
                return start + difference * animationPercentage
            }
            
            let x = interpolate(start: startFrame.origin.x, end: endFrame.origin.x)
            let y = interpolate(start: startFrame.origin.y, end: endFrame.origin.y)
            let width = interpolate(start: startFrame.width, end: endFrame.width)
            let height = interpolate(start: startFrame.height, end: endFrame.height)
            
            let currentFrame = CGRect(x: x, y: y, width: width, height: height)
            self.view.frame = currentFrame
         }
        
    }
    
}
