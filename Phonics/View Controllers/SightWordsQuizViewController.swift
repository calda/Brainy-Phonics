//
//  SightWordsQuizViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 5/23/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

struct InstructionsContent {
    static let listen = InstructionsContent(text: "Listen...", image: #imageLiteral(resourceName: "listen"))
    static let chooseWord = InstructionsContent(text: "Choose the word", image: #imageLiteral(resourceName: "button-question"))
    static let correct = InstructionsContent(text: "Correct! Good job!", image: #imageLiteral(resourceName: "correct"))
    
    let text: String
    let image: UIImage
}

class SightWordsQuizViewController : InteractiveGrowViewController {
    
    
    //MARK: - Presentation
    
    static let storyboardId = "sightWordsQuiz"
    
    static func present(from source: UIViewController, using sightWords: SightWordsManager) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as! SightWordsQuizViewController
        controller.sightWords = sightWords
        source.present(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Setup
    
    var sightWords: SightWordsManager!
    var remainingWords: [SightWord] = []
    var currentWord: SightWord?
    
    var currentlyAnimating = false
    var timers = [Timer]()
    
    @IBOutlet var answerLabels: [UILabel]!
    var originalCenters = [UIView : CGPoint]()
    
    @IBOutlet weak var answersView: UIView!
    @IBOutlet weak var buttonArea: UIView!
    
    @IBOutlet weak var instructionsPill: UIView!
    @IBOutlet weak var instructionsImage: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        self.view.backgroundColor = sightWords.category.color
        self.buttonArea.backgroundColor = sightWords.category.color
        
        for label in answerLabels {
            guard let superview = label.superview else { continue }
            self.originalCenters[superview] = superview.center
        }
        
        self.updateInstructions(with: .listen, animate: false)
        self.setupForNewWord(animateTransition: false)
    }
    
    func setupForNewWord(animateTransition: Bool) {
        if self.remainingWords.count < 4 {
            self.remainingWords = sightWords.words.shuffled()
        }
        
        self.currentWord = self.remainingWords.popLast()
        guard let currentWord = self.currentWord else { return }
        
        let answerWords = [
            currentWord,
            self.remainingWords.popLast()!,
            self.remainingWords.popLast()!,
            self.remainingWords.popLast()!
        ]
        
        for (label, word) in zip(self.answerLabels, answerWords.shuffled()) {
            label.text = word.text
            
            if let superview = label.superview {
                superview.alpha = 1.0
                superview.center = self.originalCenters[superview] ?? superview.center
            }
        }
        
        self.updateInstructions(with: .listen, animate: true)
        
        if animateTransition {
            animateTransitionToNewWord(then: self.animateForCurrentWord)
        } else {
            self.animateForCurrentWord()
        }
    }
    
    
    //MARK: - Animations
    
    func animateTransitionToNewWord(then completion: @escaping () -> ()) {
        playTransitionForView(self.answersView,
                              duration: 0.5,
                              transition: kCATransitionPush,
                              subtype: kCATransitionFromRight,
                              timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        
        Timer.scheduleAfter(0.5, addToArray: &self.timers, handler: {
            completion()
        })
    }
    
    func animateForCurrentWord() {
        self.currentlyAnimating = true
        
        self.updateInstructions(with: .listen, animate: true)
        
        Timer.scheduleAfter(0.4, addToArray: &self.timers, handler: {
            self.currentWord?.playAudio()
        })
        
        Timer.scheduleAfter(0.4 + 0.75 + 0.5, addToArray: &self.timers, handler: {
            self.updateInstructions(with: .chooseWord, animate: true)
            self.currentlyAnimating = false
        })
    }
    
    func updateInstructions(with content: InstructionsContent, animate: Bool) {
        //do nothing if the content is already applied
        if instructionsLabel.text == content.text {
            return
        }
        
        self.instructionsImage.image = content.image
        self.instructionsLabel.text = content.text
        
        guard animate else {
            self.instructionsPill.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.instructionsLabel.alpha = 0.5
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.15, options: [], animations: {
            self.instructionsLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, animations: {
            self.instructionsPill.layoutIfNeeded()
        })
    }
    
    func userSelectedCorrectWord(from view: UIView) {
        self.currentlyAnimating = true
        PHPlayer.play("correct", ofType: "mp3")
        self.updateInstructions(with: .correct, animate: true)
        
        UIView.animate(withDuration: 0.2) {
            for answerLabel in self.answerLabels {
                if answerLabel.superview != view {
                    answerLabel.superview?.alpha = 0.0
                }
            }
        }
        
        UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 0.8, animations: {
            let relativeCenter = view.superview!.convert(self.answersView.center, from: self.answersView.superview!)
            view.center = relativeCenter
        })
        
        Timer.scheduleAfter(1.0, addToArray: &self.timers) {
            self.currentWord?.playAudio()
        }
        
        Timer.scheduleAfter(2.0, addToArray: &self.timers) {
            self.setupForNewWord(animateTransition: true)
            self.currentlyAnimating = false
        }
    }
    
    func userSelectedIncorrectWord(_ word: SightWord, from view: UIView) {
        self.currentlyAnimating = true
        shakeView(view)
        PHPlayer.play("incorrect", ofType: "mp3")
        
        UIView.animate(withDuration: 0.4) {
            view.alpha = 0.4
        }
        
        Timer.scheduleAfter(0.5, addToArray: &self.timers, handler: {
            self.updateInstructions(with: .listen, animate: true)
        })
        
        Timer.scheduleAfter(0.5 + 0.1, addToArray: &self.timers, handler: {
            self.currentWord?.playAudio()
        })
        
        Timer.scheduleAfter(0.5 + 0.1 + 1.0, addToArray: &self.timers, handler: {
            self.currentlyAnimating = false
        })
        
        Timer.scheduleAfter(0.5 + 0.1 + 1.5, addToArray: &self.timers, handler: {
            self.updateInstructions(with: .chooseWord, animate: true)
        })
        
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func repeatTapped(_ sender: Any) {
        self.animateForCurrentWord()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Interactive Growing
    
    override func interactiveGrowShouldHappenFor(_ view: UIView) -> Bool {
        let hasBeenSelectedAlready = (view.alpha != 1.0)
        return !currentlyAnimating && !hasBeenSelectedAlready
    }
    
    override func interactiveGrowScaleFor(_ view: UIView) -> CGFloat {
        return 1.075
    }
    
    override func totalDurationForInterruptedAnimationOn(_ view: UIView) -> TimeInterval? {
        return 0.25
    }
    
    override func touchUpForInteractiveView(_ view: UIView) {
        let selectedText = (view.subviews.first as? UILabel)?.text
        
        guard let sightWord = sightWords.words.first(where: { $0.text == selectedText }) else {
            return
        }
        
        if sightWord == self.currentWord {
            userSelectedCorrectWord(from: view)
        } else {
            userSelectedIncorrectWord(sightWord, from: view)
        }
    }
    
}
