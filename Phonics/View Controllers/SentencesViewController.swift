//
//  SentencesViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 5/21/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

class SentencesViewController : InteractiveGrowViewController {
    
    
    //MARK: - Presentation
    
    static let storyboardId = "sentences"
    
    static func present(from source: UIViewController, for sightWord: SightWord, in sightWords: SightWordsManager) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as! SentencesViewController
        controller.currentWord = sightWord
        controller.sightWords = sightWords
        source.present(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Setup
    
    var sightWords: SightWordsManager!
    var currentWord: SightWord!
    
    var currentlyAnimating = false
    var timers = [Timer]()

    
    var currentIndex: Int? {
        return sightWords.words.index(of: currentWord)
    }
    
    var previousWord: SightWord? {
        guard let currentIndex = self.currentIndex else { return nil }
        if currentIndex == 0 { return nil }
        return sightWords.words[currentIndex - 1]
    }
    
    var nextWord: SightWord? {
        guard let currentIndex = self.currentIndex else { return nil }
        if currentIndex == sightWords.words.count - 1 { return nil }
        return sightWords.words[currentIndex + 1]
    }
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var previousWordButton: UIButton!
    @IBOutlet weak var nextWordButton: UIButton!
    @IBOutlet weak var mainButtonArea: UIView!
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var firstSentenceImageView: UIImageView!
    @IBOutlet weak var secondSentenceImageView: UIImageView!
    
    @IBOutlet weak var bottomContentContainer: UIView!
    @IBOutlet weak var focusedSentenceContainer: UIView!
    @IBOutlet weak var focusedSentenceImageView: UIImageView!
    @IBOutlet weak var focusedSentenceTextField: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.decorateForCurrentWord()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Timer.scheduleAfter(0.3, addToArray: &self.timers) {
            self.animateForCurrentWord()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UAHaltPlayback()
        timers.forEach{ $0.invalidate() }
    }
    
    func decorateForCurrentWord() {
        self.wordLabel.text = self.currentWord.text
        self.previousWordButton.isEnabled = (self.previousWord != nil)
        self.nextWordButton.isEnabled = (self.nextWord != nil)
        self.mainButtonArea.backgroundColor = self.sightWords.category.color
        
        self.firstSentenceImageView.image = self.currentWord.sentence1.image
        self.secondSentenceImageView.image = self.currentWord.sentence2.image
        
        self.focusedSentenceContainer.alpha = 0
    }
    
    
    //MARK: - Animation
    
    func animateForCurrentWord() {
        
        //cancel view animations to avoid overlap
        for view in [firstSentenceImageView, secondSentenceImageView] {
            view?.layer.removeAllAnimations()
        }
        
        self.wordLabel.layer.removeAllAnimations()
        self.timers.forEach { $0.invalidate() }
        self.timers = []
        
        self.repeatButton.isEnabled = false
        
        //play sentences
        var startTime = 0.0
        
        for sentence in [self.currentWord.sentence1, self.currentWord.sentence2] {
            
            //animate to new sentence
            Timer.scheduleAfter(startTime, addToArray: &self.timers) {
                self.focusedSentenceContainer.alpha = 1.0
                self.focusedSentenceImageView.image = sentence.image
                self.focusedSentenceTextField.attributedText = sentence.attributedText
                
                playTransitionForView(self.bottomContentContainer,
                                      duration: 0.5,
                                      transition: kCATransitionPush,
                                      subtype: kCATransitionFromRight,
                                      timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
            }
            
            startTime += 0.5 + 0.4
            
            //play audio for sentence
            Timer.scheduleAfter(startTime, addToArray: &self.timers) {
                self.pulseMainWordLabel()
                PHPlayer.play(sentence.audioFileName, ofType: "mp3")
            }
            
            startTime += UALengthOfFile(sentence.audioFileName, ofType: "mp3") + 1.0
        }
        
        //return to normal view
        Timer.scheduleAfter(startTime, addToArray: &self.timers) {
            self.focusedSentenceContainer.alpha = 0.0
            
            playTransitionForView(self.bottomContentContainer,
                                  duration: 0.5,
                                  transition: kCATransitionPush,
                                  subtype: kCATransitionFromRight,
                                  timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        
        startTime += 0.5
        
        Timer.scheduleAfter(startTime, addToArray: &self.timers) {
            self.repeatButton.isEnabled = true
        }
    }
    
    func pulseMainWordLabel(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, animations: {
            self.wordLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            self.wordLabel.alpha = 1.0
        })
        
        UIView.animate(withDuration: 0.5, delay: duration, usingSpringWithDamping: 1.0, animations: {
            self.wordLabel.transform = .identity
        })
    }
    
    
    
    //MARK: - User Interaction
    
    override func interactiveGrowScaleFor(_ view: UIView) -> CGFloat {
        return 1.125
    }
    
    override func totalDurationForInterruptedAnimationOn(_ view: UIView) -> TimeInterval? {
        return 0.3
    }
    
    override func touchUpForInteractiveView(_ view: UIView) {
        print(view)
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func repeatButtonPressed(_ sender: Any) {
        self.animateForCurrentWord()
    }
    
    @IBAction func previousWordPressed(_ sender: Any) {
        guard let previousWord = self.previousWord else { return }
        self.currentWord = previousWord
        self.decorateForCurrentWord()
        UAHaltPlayback()
        
        Timer.scheduleAfter(0.3, addToArray: &self.timers) {
            self.animateForCurrentWord()
        }
    }
    
    @IBAction func nextWordPressed(_ sender: Any) {
        guard let nextWord = self.nextWord else { return }
        self.currentWord = nextWord
        self.decorateForCurrentWord()
        UAHaltPlayback()
        
        Timer.scheduleAfter(0.3, addToArray: &self.timers) {
            self.animateForCurrentWord()
        }
    }
}
