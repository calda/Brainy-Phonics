//
//  PuzzleDetailViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 12/19/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class PuzzleDetailViewController : UIViewController {
    
    @IBOutlet weak var puzzleView: PuzzleView!
    @IBOutlet weak var puzzleViewCenterHorizontally: NSLayoutConstraint!
    
    @IBOutlet weak var rhymeText: UITextView!
    @IBOutlet weak var rhymeTextHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrim: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    
    var oldPuzzleView: PuzzleView!
    var puzzleShadow: UIView!
    var animationImage: UIImageView!
    var sound: Sound!
    var notifyOfDismissal: (() -> Void)?
    
    
    //MARK: - Presentation
    
    static func present(for sound: Sound, from puzzleView: PuzzleView, with puzzleShadow: UIView, in source: UIViewController, onDismiss: (() -> Void)?) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let puzzleDetail = storyboard.instantiateViewController(withIdentifier: "puzzle detail") as? PuzzleDetailViewController else { return }
        
        puzzleDetail.oldPuzzleView = puzzleView
        puzzleDetail.puzzleShadow = puzzleShadow
        puzzleDetail.sound = sound
        puzzleDetail.notifyOfDismissal = onDismiss
        
        puzzleDetail.modalPresentationStyle = .overCurrentContext
        
        source.present(puzzleDetail, animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        updateAccessoryViews(visible: false)
        self.puzzleView.alpha = 0.0
        
        if let oldPuzzleView = self.oldPuzzleView, let puzzle = oldPuzzleView.puzzle {
            self.puzzleView.puzzleName = oldPuzzleView.puzzleName
            self.puzzleView.isPieceVisible = oldPuzzleView.isPieceVisible
            
            if Player.current.progress(for: puzzle).isComplete, let rhymeText = self.sound.rhymeText {
                self.prepareRhymeText(for: rhymeText)
            } else {
                //center the puzzle and hide the rhyme text
                self.puzzleViewCenterHorizontally.priority = UILayoutPriorityDefaultHigh
                self.rhymeText.isHidden = true
                self.puzzleView.layoutIfNeeded()
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //create image and then animate
        guard let oldPuzzleView = self.oldPuzzleView else { return }
        let translatedFrame = self.view.convert(oldPuzzleView.bounds, from: oldPuzzleView)
        
        self.animationImage = UIImageView(image: puzzleView.asImage)
        
        animationImage.frame = translatedFrame
        self.view.addSubview(animationImage)
        oldPuzzleView.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            
            self.animationImage.frame = self.puzzleView.frame
            self.updateAccessoryViews(visible: true)
            
        }, completion: { _ in
            if let puzzle = self.puzzleView.puzzle,
               Player.current.progress(for: puzzle).isComplete {
                self.playAudio(self)
            }
            
            self.puzzleView.alpha = 1.0
            UIView.animate(withDuration: 0.225, delay: 0.0, options: [], animations: {
                self.animationImage.alpha = 0.0
            }, completion: nil)
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1.0) {
            self.rhymeText.transform = .identity
        }
    }
    
    func updateAccessoryViews(visible: Bool) {
        let views: [UIView] = [scrim, backButton, repeatButton, blurView, rhymeText]
        let commonAlpha: CGFloat = (visible ? 1.0 : 0.0)
        
        for view in views {
            view.alpha = commonAlpha
        }
        
        self.puzzleShadow.alpha = (visible ? 0.0 : 1.0)
    }
    
    func prepareRhymeText(for text: String) {
        //move down to prepare for animation
        rhymeText.transform = CGAffineTransform(translationX: 0, y: 50)
        
        rhymeText.clipsToBounds = false
        rhymeText.layer.masksToBounds = false
        self.repeatButton.isHidden = false
        
        //build attributed string
        let attributes = rhymeText.attributedText.attributes(at: 0, effectiveRange: nil)
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        rhymeText.attributedText = attributedText
        
        //update height for
        let idealHeight = heightForText(text, width: rhymeText.frame.width, attributes: attributes) + 10
        let maxPossibleHeight = self.view.frame.height - 50 // 50 = padding on top/bottom
        
        if idealHeight < maxPossibleHeight {
            rhymeTextHeight.constant = idealHeight
            rhymeText.isUserInteractionEnabled = false
        } else {
            rhymeTextHeight.constant = maxPossibleHeight
            rhymeText.isUserInteractionEnabled = true
        }
        
        rhymeText.layoutIfNeeded()
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func backTapped(_ sender: Any) {
        
        UAHaltPlayback()
        self.puzzleView.alpha = 0.0
        self.animationImage.alpha = 1.0
        
        //grab new image
        self.animationImage.image = self.oldPuzzleView.asImage
        
        //animate
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
        
            guard let oldPuzzleView = self.oldPuzzleView else { return }
            let translatedFrame = self.view.convert(oldPuzzleView.bounds, from: oldPuzzleView)
            self.animationImage.frame = translatedFrame
            
            self.updateAccessoryViews(visible: false)
        
        }, completion: { _ in
            self.oldPuzzleView.alpha = 1.0
            self.dismiss(animated: false, completion: nil)
            
            self.notifyOfDismissal?()
        })
    }
    
    @IBAction func playAudio(_ sender: Any) {
        let audioName = sound.rhymeAudioName
        PHPlayer.play(audioName, ofType: "mp3")
        self.repeatButton.isEnabled = false
        
        UAWhenDonePlayingAudio {
            self.repeatButton.isEnabled = true
        }
    }
    
    
}


extension UIView {
 
    var asImage: UIImage? {
        let previousAlpha = self.alpha
        self.alpha = 1.0
        
        let deviceScale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, deviceScale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        self.alpha = previousAlpha
        return image
    }
    
}



