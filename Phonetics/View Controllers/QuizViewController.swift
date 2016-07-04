//
//  QuizViewController.swift
//  Phonetics
//
//  Created by Cal on 7/3/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit

class QuizViewController : InteractiveGrowViewController {
    
    var letterPool: [Letter]!
    var currentLetter: Letter!
    var currentSound: Sound!
    var answerWord: Word!
    
    @IBOutlet var wordViews: [WordView]!
    @IBOutlet weak var soundLabel: UILabel!
    
    var currentlyAnimating = false
    var timers = [NSTimer]()
    
    
    //MARK: - Content Setup
    
    override func viewWillAppear(animated: Bool) {
        sortOutletCollectionByTag(&wordViews)
        letterPool = PHContent.letters.map{ (_, letter) in letter }
        setupForRandomSoundFromPool()
    }
    
    func setupForRandomSoundFromPool() {
        let isFirst = (currentSound == nil)
        self.currentLetter = letterPool.random()
        self.currentSound = currentLetter.sounds.random()
        self.answerWord = currentSound.words.random()
        
        soundLabel.text = self.currentSound.displayString
        
        let allWords = PHContent.allWordsNoDuplicates
        let blacklistedSound = currentSound.ipaPronunciation
        let blacklistedLetter = currentSound.sourceLetter.lowercaseString
        let possibleWords = allWords.filter{ word in
            return !word.pronunciation.containsString(blacklistedSound)
                    && !word.text.lowercaseString.containsString(blacklistedLetter)
        }
        
        var selectedWords: [Word] = [answerWord]
        while selectedWords.count != wordViews.count {
            if let candidateWord = possibleWords.random() where !selectedWords.contains(candidateWord) {
                selectedWords.append(candidateWord)
            }
        }
        
        selectedWords = selectedWords.shuffled()
        
        for (index, wordView) in wordViews.enumerate() {
            wordView.useWord(selectedWords[index], forSound: currentSound, ofLetter: currentLetter)
        }
        
        transitionToCurrentSound(isFirst: isFirst)
    }
    
    
    //MARK: - Animation
    
    func transitionToCurrentSound(isFirst isFirst: Bool) {
        //animate if not first
        if !isFirst {
            for view in [wordViews.first!.superview!, self.soundLabel.superview!] {
                playTransitionForView(view, duration: 0.5, transition: kCATransitionPush, subtype: kCATransitionFromTop,
                                      timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
            }
        }
        
        delay(0.5) {
            self.playQuestionAnimation()
        }
    }
    
    func playQuestionAnimation() {
        
        self.currentlyAnimating = true
        var startTime: NSTimeInterval = 0.0
        let timeBetween = 0.85
        
        NSTimer.scheduleAfter(startTime, addToArray: &timers) { _ in
            shakeView(self.soundLabel)
        }
        
        NSTimer.scheduleAfter(startTime - 0.3, addToArray: &timers) { _ in
            PHContent.playAudioForInfo(self.currentSound.pronunciationTiming)
        }
        
        startTime += self.currentSound.pronunciationTiming.wordDuration + timeBetween
        
        for (index, wordView) in self.wordViews.enumerate() {
            
            NSTimer.scheduleAfter(startTime, addToArray: &self.timers) { _ in
                self.playSoundAnimationForWord(index, delayAnimationBy: 0.3)
            }
            
            startTime += (wordView.word?.audioInfo?.wordDuration ?? 0.0) + timeBetween
            
            if (wordView == self.wordViews.last) {
                NSTimer.scheduleAfter(startTime - timeBetween, addToArray: &self.timers) { _ in
                    self.currentlyAnimating = false
                }
            }
        }
    }
    
    func playSoundAnimationForWord(index: Int, delayAnimationBy delay: NSTimeInterval = 0.0, extendAnimationBy extend: NSTimeInterval = 0.0) {
        if index >= self.wordViews.count { return }
        
        let wordView = self.wordViews[index]
        guard let word = wordView.word else { return }
        word.playAudio()
        
        UIView.animateWithDuration(0.4, delay: delay, usingSpringWithDamping: 0.8, animations: {
            wordView.transform = CGAffineTransformMakeScale(1.1, 1.1)
            wordView.alpha = 1.0
        })
        
        UIView.animateWithDuration(0.5, delay: delay + extend + (word.audioInfo?.wordDuration ?? 0.5), usingSpringWithDamping: 1.0, animations: {
            wordView.transform = CGAffineTransformIdentity
        })
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func repeatSound(sender: UIButton) {
        if self.currentlyAnimating { return }
        
        sender.userInteractionEnabled = false
        delay(1.0) {
            sender.userInteractionEnabled = true
        }
        
        //sender.tag = 0  >>  repeat Sound Animation
        //sender.tag = 1  >>  repeat pronunciation
        
        if (sender.tag == 0) {
            playQuestionAnimation()
        } else if sender.tag == 1 {
            PHContent.playAudioForInfo(currentSound.pronunciationTiming)
            shakeView(self.soundLabel)
        }
    }
    
    override func interactiveGrowScaleFor(view: UIView) -> CGFloat {
        return 1.1
    }
    
    override func interactiveGrowShouldHappenFor(view: UIView) -> Bool {
        return !currentlyAnimating
    }
    
    override func interactiveGrowActionFor(view: UIView) {
        if let wordView = view as? WordView {
            wordView.word?.playAudio()
        }
    }
    
    @IBAction func tempReloadPressed(sender: UIButton) {
        self.setupForRandomSoundFromPool()
    }
    
}