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
        Timer.scheduleAfter(0.4, addToArray: &self.timers) {
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
        
        self.currentlyAnimating = true
        self.repeatButton.isEnabled = false
        self.focusedSentenceTextField.alpha = 1.0
        
        var startTime = 0.0
        
        //show first sentence
        Timer.scheduleAfter(startTime, addToArray: &self.timers, handler: {
            self.focusedSentenceTextField.attributedText = self.currentWord.sentence1.attributedText
            self.animateImage(from: self.firstSentenceImageView, to: self.focusedSentenceImageView, duration: 0.65)
            
            UIView.animate(withDuration: 0.3) {
                self.focusedSentenceContainer.alpha = 1.0
            }
        })
        
        startTime += 0.5
        
        //play first sentence
        Timer.scheduleAfter(startTime, addToArray: &self.timers, handler: {
            self.pulseMainWordLabel()
            PHPlayer.play(self.currentWord.sentence1.audioFileName, ofType: "mp3")
        })
        
        startTime += UALengthOfFile(self.currentWord.sentence1.audioFileName, ofType: "mp3") + 1.0
        
        //show second sentence
        Timer.scheduleAfter(startTime, addToArray: &self.timers, handler: {
            self.focusedSentenceImageView.image = self.currentWord.sentence2.image
            self.focusedSentenceTextField.attributedText = self.currentWord.sentence2.attributedText
            
            self.animateContentView(direction: .left, duration: 0.5)
        })
        
        startTime += 0.5
        
        //play second sentence
        Timer.scheduleAfter(startTime, addToArray: &self.timers, handler: {
            self.pulseMainWordLabel()
            PHPlayer.play(self.currentWord.sentence2.audioFileName, ofType: "mp3")
        })
        
        startTime += UALengthOfFile(self.currentWord.sentence2.audioFileName, ofType: "mp3") + 1.0
        
        //animate to regular state
        Timer.scheduleAfter(startTime, addToArray: &self.timers, handler: {
            self.animateImage(from: self.focusedSentenceImageView, to: self.secondSentenceImageView, duration: 0.65)
            
            UIView.animate(withDuration: 0.3) {
                self.focusedSentenceContainer.alpha = 0.0
                self.focusedSentenceTextField.alpha = 0.0
                self.repeatButton.isEnabled = true
                self.currentlyAnimating = false
            }
        })
    }
    
    func animateSentence(for imageView: UIImageView) {
        guard imageView == self.firstSentenceImageView || imageView == self.secondSentenceImageView else {
            return
        }
        
        let sentence = (imageView == self.firstSentenceImageView)
                        ? self.currentWord.sentence1
                        : self.currentWord.sentence2
        
        self.currentlyAnimating = true
        self.repeatButton.isEnabled = false
        self.focusedSentenceTextField.alpha = 1.0
        
        var startTime = 0.0
        
        //show sentence
        Timer.scheduleAfter(startTime, addToArray: &self.timers, handler: {
            self.focusedSentenceTextField.attributedText = sentence.attributedText
            self.animateImage(from: imageView, to: self.focusedSentenceImageView, duration: 0.65)
            
            UIView.animate(withDuration: 0.3) {
                self.focusedSentenceContainer.alpha = 1.0
            }
        })
        
        startTime += 0.5
        
        //play sentence
        Timer.scheduleAfter(startTime, addToArray: &self.timers, handler: {
            self.pulseMainWordLabel()
            PHPlayer.play(sentence.audioFileName, ofType: "mp3")
        })
        
        startTime += UALengthOfFile(sentence.audioFileName, ofType: "mp3") + 1.0
        
        //hide sentence
        Timer.scheduleAfter(startTime, addToArray: &self.timers, handler: {
            self.animateImage(from: self.focusedSentenceImageView, to: imageView, duration: 0.65)
            
            UIView.animate(withDuration: 0.3) {
                self.focusedSentenceContainer.alpha = 0.0
                self.focusedSentenceTextField.alpha = 0.0
                self.repeatButton.isEnabled = true
                self.currentlyAnimating = false
            }
        })
    }
    
    
    //MARK: Animation Helpers
    
    enum Direction: String {
        case left
        case right
        
        var animationSubtype: String {
            switch(self) {
            case .left: return kCATransitionFromRight
            case .right: return kCATransitionFromLeft
            }
        }
    }
    
    func animateContentView(direction: Direction, duration: TimeInterval) {
        playTransitionForView(self.bottomContentContainer,
                              duration: duration,
                              transition: kCATransitionPush,
                              subtype: direction.animationSubtype,
                              timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
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
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func repeatButtonPressed(_ sender: Any) {
        self.animateForCurrentWord()
    }
    
    @IBAction func previousWordPressed(_ sender: Any) {
        guard let previousWord = self.previousWord else { return }
        self.currentWord = previousWord
        
        self.timers.forEach{ $0.invalidate() }
        UAHaltPlayback()
        
        self.decorateForCurrentWord()
        self.animateContentView(direction: .right, duration: 0.5)
        
        Timer.scheduleAfter(0.75, addToArray: &self.timers) {
            self.animateForCurrentWord()
        }
    }
    
    @IBAction func nextWordPressed(_ sender: Any) {
        guard let nextWord = self.nextWord else { return }
        self.currentWord = nextWord
        
        self.timers.forEach{ $0.invalidate() }
        UAHaltPlayback()
        
        self.decorateForCurrentWord()
        self.animateContentView(direction: .left, duration: 0.5)
        
        Timer.scheduleAfter(0.75, addToArray: &self.timers) {
            self.animateForCurrentWord()
        }
    }
    
    
    //MARK: InteractiveGrowViewController Interaction
    
    override func interactiveGrowScaleFor(_ view: UIView) -> CGFloat {
        return 1.125
    }
    
    override func totalDurationForInterruptedAnimationOn(_ view: UIView) -> TimeInterval? {
        return 0.3
    }
    
    override func touchUpForInteractiveView(_ view: UIView) {
        guard !currentlyAnimating else { return }
        
        if let imageView = view as? UIImageView {
            self.animateSentence(for: imageView)
        }
    }
    
}
