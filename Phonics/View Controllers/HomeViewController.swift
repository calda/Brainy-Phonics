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
    
    
    //TODO: create assets that are more appropriately sizes / don't rasterize poorly
    
    @IBOutlet weak var alphabetLettersView: UIImageView!
    @IBOutlet weak var phonicsView: UIImageView!
    @IBOutlet weak var prekSightWordsView: UIImageView!
    @IBOutlet weak var kindergartenSightWordsView: UIImageView!
    @IBOutlet weak var brainyPhonicsView: UIImageView!
    
    
    
    //MARK: - Content
    
    struct Launcher {
        let audioFileName: String
        let onTapBlock: ((UIViewController) -> ())?
        
        static let brainyPhonics = Launcher(audioFileName: "brainy phonics", onTapBlock: nil)
        
        static let alphabetLetters = Launcher(audioFileName: "alphabet letters", onTapBlock: { vc in
            LettersViewController.present(from: vc, with: .easyDifficulty)
        })
        
        static let phonics = Launcher(audioFileName: "phonics", onTapBlock: { vc in
            LettersViewController.present(from: vc, with: .standardDifficulty)
        })
        
        static let prekSightWords = Launcher(audioFileName: "pre-k sight words", onTapBlock: { vc in
            SightWordsViewController.present(from: vc, using: PHContent.sightWordsPreK)
        })
        
        static let kindergartenSightWords = Launcher(audioFileName: "kindergarten sight words", onTapBlock: { vc in
            SightWordsViewController.present(from: vc, using: PHContent.sightWordsKindergarten)
        })
    }
    
    func launcher(for view: UIView) -> Launcher? {
        switch(view) {
            case brainyPhonicsView: return .brainyPhonics
            case alphabetLettersView: return .alphabetLetters
            case phonicsView: return .phonics
            case prekSightWordsView: return .prekSightWords
            case kindergartenSightWordsView: return .kindergartenSightWords
            default: return nil
        }
    }
    
    
    //MARK: - User Interaction
    
    override func interactiveGrowScaleFor(_ view: UIView) -> CGFloat {
        return 1.1
    }
    
    override func totalDurationForInterruptedAnimationOn(_ view: UIView) -> TimeInterval? {
        if let launcher = launcher(for: view) {
            return UALengthOfFile(launcher.audioFileName, ofType: "mp3")
        } else {
            return 0
        }
    }
    
    override func interactiveViewWilGrow(_ view: UIView) {
        //there's a very interesting bug where this will get triggered from the PuzzleDetailViewController later in the chain... not sure how that happens, but this should stop it.
        guard self.presentedViewController == nil else {
            return
        }
        
        if let launcher = launcher(for: view) {
            PHPlayer.play(launcher.audioFileName, ofType: "mp3")
        }
    }
    
    override func touchUpForInteractiveView(_ view: UIView) {
        guard let launcher = launcher(for: view) else {
            return
        }
        
        UAWhenDonePlayingAudio {
            launcher.onTapBlock?(self)
        }
    }
    
}
