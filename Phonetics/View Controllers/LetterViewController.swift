//
//  LetterViewController.swift
//  Phonetics
//
//  Created by Cal on 6/5/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class LetterViewController : InteractiveGrowViewController {
    
    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var previousSoundButton: UIButton!
    @IBOutlet weak var nextSoundButton: UIButton!
    @IBOutlet weak var wordsView: UIView!
    
    @IBOutlet var wordViews: [WordView]!
    
    var letter: Letter!
    var sound: Sound!
    var timers = [NSTimer]()
    var currentlyPlaying = false
    
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
        sortOutletCollectionByTag(&wordViews)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UAHaltPlayback()
    }
    
    func decorateForCurrentSound(withTransition transition: Bool = false, withAnimationDelay: Bool = true, animationSubtype: String? = nil) {
        if currentlyPlaying {
            //cancel view animations to avoid overlap
            for view in wordViews {
                view.layer.removeAllAnimations()
            }
            self.letterLabel.layer.removeAllAnimations()
            self.timers.forEach { $0.invalidate() }
            self.timers = []
        }
        
        //set up view
        self.letterLabel.text = sound.displayString
        self.previousSoundButton.enabled = previousSound != nil
        self.nextSoundButton.enabled = nextSound != nil
        
        for i in 0...2 {
            let wordView = wordViews[i]
            wordView.alpha = withAnimationDelay ? 0.0 : 1.0
            wordView.useWord(self.sound.words[i], forSound: self.sound, ofLetter: self.letter)
        }
        
        //play audio, cue animations
        if !withAnimationDelay {
            self.playSoundAnimation()
        } else {
            NSTimer.scheduleAfter(0.4, addToArray: &self.timers) { _ in
                self.playSoundAnimation()
            }
        }
        
        if transition {
            let views = [letterLabel, wordsView]
            for view in views {
                playTransitionForView(view, duration: 0.5, transition: kCATransitionPush, subtype: animationSubtype,
                                      timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
            }
        }
    }
    
    
    func playSoundAnimation() {
        
        self.currentlyPlaying = true
        var startTime: NSTimeInterval = 0.0
        let timeBetween = 0.85
        
        if let sourceLetterInfo = self.sound.sourceLetterTiming {
            PHContent.playAudioForInfo(sourceLetterInfo)
            startTime += sourceLetterInfo.wordDuration + timeBetween
        }
        
        NSTimer.scheduleAfter(startTime, addToArray: &timers) { _ in
            shakeView(self.letterLabel)
        }
        
        NSTimer.scheduleAfter(startTime - 0.3, addToArray: &timers) { _ in
            PHContent.playAudioForInfo(self.sound.pronunciationTiming)
        }
        
        startTime += self.sound.pronunciationTiming.wordDuration + timeBetween
        
        for (index, word) in self.sound.words.enumerate() {
            
            
            NSTimer.scheduleAfter(startTime, addToArray: &self.timers) { _ in
                self.playSoundAnimationForWord(index, delayAnimationBy: 0.3)
            }
            
            startTime += (word.audioInfo?.wordDuration ?? 0.0) + timeBetween
            
            if (word == self.sound.words.last) {
                NSTimer.scheduleAfter(startTime - timeBetween, addToArray: &self.timers) { _ in
                    self.currentlyPlaying = false
                }
            }
        }
    }
    
    func playSoundAnimationForWord(index: Int, delayAnimationBy delay: NSTimeInterval = 0.0, extendAnimationBy extend: NSTimeInterval = 0.0) {
        if index >= self.sound.words.count { return }
        
        let word = self.sound.words[index]
        let wordView = self.wordViews[index]
        word.playAudio()
        
        UIView.animateWithDuration(0.4, delay: delay, usingSpringWithDamping: 0.8, animations: {
            wordView.transform = CGAffineTransformMakeScale(1.15, 1.15)
            wordView.alpha = 1.0
        })
        
        UIView.animateWithDuration(0.5, delay: delay + extend + (word.audioInfo?.wordDuration ?? 0.5), usingSpringWithDamping: 1.0, animations: {
            wordView.transform = CGAffineTransformIdentity
        })
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func backPressed(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func repeatPressed(sender: UIButton) {
        if self.currentlyPlaying { return }
        
        sender.userInteractionEnabled = false
        delay(1.0) {
            sender.userInteractionEnabled = true
        }
        
        //sender.tag = 0  >>  repeat Sound Animation
        //sender.tag = 1  >>  repeat pronunciation
        
        if (sender.tag == 0) {
            decorateForCurrentSound(withTransition: false, withAnimationDelay: false, animationSubtype: kCATransitionFade)
        } else if sender.tag == 1 {
            PHContent.playAudioForInfo(sound.pronunciationTiming)
            shakeView(self.letterLabel)
        }
    }
    
    @IBAction func previousSoundPressed(sender: AnyObject) {
        sound = previousSound ?? sound
        decorateForCurrentSound(withTransition: true, animationSubtype: kCATransitionFromLeft)
    }
    
    @IBAction func nextSoundPressed(sender: AnyObject) {
        sound = nextSound ?? sound
        decorateForCurrentSound(withTransition: true, animationSubtype: kCATransitionFromRight)
    }
    
    
    //MARK: - Interactive Grow behavior
    
    override func interactiveViewWilGrow(view: UIView) {
        if let wordView = view as? WordView {
            wordView.word?.playAudio()
        }
    }
    
    override func totalDurationForInterruptedAnimationOn(view: UIView) -> NSTimeInterval? {
        if let wordView = view as? WordView, let duration = wordView.word?.audioInfo?.wordDuration {
            return duration + 0.5
        } else { return 1.0 }
    }
    
    override func interactiveGrowScaleFor(view: UIView) -> CGFloat {
        return 1.15
    }
    
    override func interactiveGrowShouldHappenFor(view: UIView) -> Bool {
        return !self.currentlyPlaying
    }
    
}
