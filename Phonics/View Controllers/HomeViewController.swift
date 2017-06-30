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
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var alphabetLettersView: UIImageView!
    @IBOutlet weak var phonicsView: UIImageView!
    @IBOutlet weak var prekSightWordsView: UIImageView!
    @IBOutlet weak var kindergartenSightWordsView: UIImageView!
    @IBOutlet weak var secretStuffView: UIImageView!
    
    private var temporaryImageView: UIImageView?
    
    //MARK: - Content
    
    struct Launcher {
        let audioFileName: String
        let onTapBlock: ((UIViewController) -> ())?
        
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
        
        static let pigLatin = Launcher(audioFileName: "secret child stuff", onTapBlock: { vc in
            PigLatinViewController.present(from: vc)
        })
    }
    
    func launcher(for view: UIView) -> Launcher? {
        switch(view) {
            case alphabetLettersView: return .alphabetLetters
            case phonicsView: return .phonics
            case prekSightWordsView: return .prekSightWords
            case kindergartenSightWordsView: return .kindergartenSightWords
            case secretStuffView: return .pigLatin
            default: return nil
        }
    }
    
    //MARK: - Setup
    
    override func viewWillAppear(_ animated: Bool) {
        //tear down any previous animations
        temporaryImageView?.removeFromSuperview()
        
        for view in interactiveViews {
            view.transform = .identity
            view.alpha = 1.0
        }
        
        self.view.isUserInteractionEnabled = true
    }
    
    //MARK: - User Interaction
    
    override func interactiveGrowShouldHappenFor(_ view: UIView) -> Bool {
        if view.transform != .identity { return true }
        
        return !UAIsAudioPlaying()
    }
    
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
    
    //MARK: Animate selection
    
    override func touchUpForInteractiveView(_ view: UIView) {
        guard let launcher = launcher(for: view), let imageView = (view as? UIImageView) else {
            return
        }
        
        self.view.isUserInteractionEnabled = false
        
        //animate
        
        UIView.animate(withDuration: 0.15, animations: {
            for other in self.interactiveViews {
                other.alpha = 0.00
            }
        })
        
        let newImageView = UIImageView(image: imageView.image, highlightedImage: nil)
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(newImageView)
        newImageView.contentMode = .scaleAspectFit
        newImageView.constraintInCenterOfSuperview()
        newImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
        newImageView.heightAnchor.constraint(equalTo: newImageView.widthAnchor, multiplier: 1.0).isActive = true
        
        newImageView.alpha = 0.0
        newImageView.transform = CGAffineTransform(translationX: 0, y: contentView.frame.height * 0.025)
        
        UIView.animate(withDuration: 0.55, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [], animations: {
            newImageView.transform = .identity
            newImageView.alpha = 1.0
        }, completion: nil)
        
        self.temporaryImageView = newImageView
        
        UAWhenDonePlayingAudio {
            delay(1.0) {
                launcher.onTapBlock?(self)
            }
        }
    }
    
    func animateImage(from origin: UIImageView, to destination: UIImageView, duration: TimeInterval) {
        let originFrame = origin.convert(origin.bounds, to: self.view)
        let destinationFrame = destination.convert(destination.bounds, to: self.view)
        
        let temporaryImageView = UIImageView(image: origin.image)
        temporaryImageView.contentMode = .scaleAspectFit
        self.view.addSubview(temporaryImageView)
        temporaryImageView.frame = originFrame
        
        origin.alpha = 0.0
        destination.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.0, options: [], animations: {
            temporaryImageView.frame = destinationFrame
        }, completion: { _ in
            temporaryImageView.removeFromSuperview()
            origin.alpha = 1.0
            destination.alpha = 1.0
            destination.image = origin.image
        })
    }
    
}
