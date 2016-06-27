//
//  LetterViewController.swift
//  Phonetics
//
//  Created by Cal on 6/5/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class LetterViewController : UIViewController {
    
    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var previousSoundButton: UIButton!
    @IBOutlet weak var nextSoundButton: UIButton!
    @IBOutlet weak var wordsView: UIView!
    
    @IBOutlet weak var word1Label: UILabel!
    @IBOutlet weak var word2Label: UILabel!
    @IBOutlet weak var word3Label: UILabel!
    
    @IBOutlet weak var word1Image: UIImageView!
    @IBOutlet weak var word2Image: UIImageView!
    @IBOutlet weak var word3Image: UIImageView!
    
    func labelAndImageForWord(word: Int) -> (UILabel, UIImageView) {
        if word == 1 { return (word1Label, word1Image) }
        else if word == 2 { return (word2Label, word2Image) }
        else { return (word3Label, word3Image) }
    }
    
    var letter: Letter!
    var sound: Sound!
    
    var previousSound: Sound? {
        let prev = letter.sounds.indexOf(sound)!.predecessor()
        if prev < 0 { return nil }
        return letter.sounds[prev]
    }
    
    var nextSound: Sound? {
        let next = letter.sounds.indexOf(sound)!.successor()
        if next >= letter.sounds.count { return nil }
        return letter.sounds[next]
    }
    
    
    //MARK: - Presentation
    
    static func presentForLetter(letter: String, inController other: UIViewController) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("letter") as! LetterViewController
        controller.letter = PHContent[letter]!
        controller.sound = controller.letter.sounds.first
        other.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Set up
    
    override func viewWillAppear(animated: Bool) {
        decorateForCurrentSound()
    }
    
    override func viewWillDisappear(animated: Bool) {
        UAHaltPlayback()
    }
    
    func decorateForCurrentSound(withAnimation animate: Bool = false, animationSubtype: String? = nil) {
        if UAIsAudioPlaying() {
            //cancel audio playback and view animations to avoid overlap
            UAHaltPlayback()
            delay(0.1) {
                (1...3).map{ self.labelAndImageForWord($0).0.superview }.forEach{ $0?.layer.removeAllAnimations() }
                self.decorateForCurrentSound(withAnimation: animate, animationSubtype: animationSubtype)
            }
            return
        }
        
        //set up view
        self.letterLabel.text = sound.displayString
        self.previousSoundButton.enabled = previousSound != nil
        self.nextSoundButton.enabled = nextSound != nil
        
        for wordNumber in (1...3) {
            
            let (label, imageView) = labelAndImageForWord(wordNumber)
            label.superview?.alpha = 0.0
            
            if sound.words.count < wordNumber {
                label.text = nil
                imageView.image = nil
                continue
            }
            
            let word = sound.words[wordNumber - 1]
            label.attributedText = word.attributedText(forSound: sound, ofLetter: letter)
            imageView.image = word.image
        }
        
        //cplay audio, cue animations
        delay(0.4) {
            PHPlayer.play(self.sound.audioName(withWords: true), ofType: "mp3")
            
            delay(self.sound.pronunciationTiming.wordStart - 0.3) {
                shakeView(self.letterLabel)
            }
            
            for i in 0 ..< self.sound.words.count {
                let word = self.sound.words[i]
                let wordView = self.labelAndImageForWord(i + 1).0.superview!
                
                UIView.animateWithDuration(0.4, delay: word.audioStartTime, usingSpringWithDamping: 0.8, animations: {
                    wordView.transform = CGAffineTransformMakeScale(1.15, 1.15)
                    wordView.alpha = 1.0
                })
                
                UIView.animateWithDuration(0.5, delay: word.audioStartTime + word.audioDuration, usingSpringWithDamping: 1.0, animations: {
                    wordView.transform = CGAffineTransformIdentity
                })
            }
        }
        
        if animate {
            
            let views = [letterLabel, wordsView]
            for view in views {
                playTransitionForView(view, duration: 0.5, transition: kCATransitionPush, subtype: animationSubtype,
                                      timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
            }
        }
        
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func backPressed(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func previousSoundPressed(sender: AnyObject) {
        sound = previousSound ?? sound
        decorateForCurrentSound(withAnimation: true, animationSubtype: kCATransitionFromLeft)
    }
    
    @IBAction func nextSoundPressed(sender: AnyObject) {
        sound = nextSound ?? sound
        decorateForCurrentSound(withAnimation: true, animationSubtype: kCATransitionFromRight)
    }
}
