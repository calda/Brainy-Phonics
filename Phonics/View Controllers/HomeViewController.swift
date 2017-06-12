//
//  HomeViewController.swift
//  Phonetics
//
//  Created by Cal on 7/4/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController : InteractiveGrowViewController {
    
    @IBOutlet weak var phonicsView: UIImageView!
    @IBOutlet weak var sightWordsView: UIImageView!
    @IBOutlet weak var brainyPhonicsLabel: UILabel!
    
    //MARK: - User Interaction
    
    override func interactiveGrowScaleFor(_ view: UIView) -> CGFloat {
        return 1.1
    }
    
    override func totalDurationForInterruptedAnimationOn(_ view: UIView) -> TimeInterval? {
        if view == phonicsView {
            return UALengthOfFile("phonics", ofType: "mp3")
        } else if view == sightWordsView  {
            return UALengthOfFile("sight words", ofType: "mp3")
        } else if view == brainyPhonicsLabel {
            return UALengthOfFile("brainy phonics", ofType: "mp3")
        } else {
            return 0
        }
    }
    
    override func interactiveViewWilGrow(_ view: UIView) {
        if view == phonicsView {
            PHPlayer.play("phonics", ofType: "mp3")
        } else if view == sightWordsView  {
            PHPlayer.play("sight words", ofType: "mp3")
        } else if view == brainyPhonicsLabel {
            PHPlayer.play("brainy phonics", ofType: "mp3")
        }
    }
    
    override func touchUpForInteractiveView(_ view: UIView) {
        UAWhenDonePlayingAudio {
            if view == self.phonicsView {
                self.presentPhonics()
            } else if view == self.sightWordsView {
                self.presentSightWords()
            }
        }
    }
    
    
    //MARK: - Transitions
    
    func presentPhonics() {
        let alert = UIAlertController(title: "Phonics Difficulty", message: "This probably shouldn't be here. I imagine the player's age/grade will be set somewhere else, like on first launch / in settings, and then this automatically opens the correct content.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Simple (Pre-K?)", style: .default, handler: { _ in
            LettersViewController.present(from: self, with: .easyDifficulty)
        }))
        
        alert.addAction(UIAlertAction(title: "Regular (Kindergarten?)", style: .default, handler: { _ in
            LettersViewController.present(from: self, with: .standardDifficulty)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentSightWords() {
        let alert = UIAlertController(title: "Sight Words Level", message: "This probably shouldn't be here. I imagine the player's age/grade will be set somewhere else, like on first launch / in settings, and then this automatically opens the correct content.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Pre-K", style: .default, handler: { _ in
            SightWordsViewController.present(from: self, using: PHContent.sightWordsPreK)
        }))
        
        alert.addAction(UIAlertAction(title: "Kindergarten", style: .default, handler: { _ in
            SightWordsViewController.present(from: self, using: PHContent.sightWordsKindergarten)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
