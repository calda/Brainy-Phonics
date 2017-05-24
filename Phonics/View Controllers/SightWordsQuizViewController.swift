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
    
    let text: String
    let image: UIImage
}

class SightWordsQuizViewController : InteractiveGrowViewController {
    
    
    //MARK: - Presentation
    
    
    //MARK: - Setup
    
    var sightWords: SightWordsManager! = PHContent.sightWordsKindergarten
    var remainingWords: [SightWord] = []
    var currentWord: SightWord?
    var timers = [Timer]()
    
    @IBOutlet var answerLabels: [UILabel]!
    @IBOutlet weak var instructionsPill: UIView!
    @IBOutlet weak var instructionsImage: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        self.view.backgroundColor = sightWords.category.color
        
        self.updateInstructions(with: .listen, animate: false)
        self.setupForNewWord()
    }
    
    func setupForNewWord() {
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
        }
        
        self.animateForCurrentWord()
    }
    
    
    //MARK: - Animations
    
    func animateForCurrentWord() {
        self.updateInstructions(with: .listen, animate: true)
        
        Timer.scheduleAfter(0.4, addToArray: &self.timers, handler: {
            self.currentWord?.playAudio()
        })
        
        Timer.scheduleAfter(0.4 + 0.75 + 0.5, addToArray: &self.timers, handler: {
            self.updateInstructions(with: .chooseWord, animate: true)
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
    
    
    //MARK: - User Interaction
    
    func userSelectedCorrectWord(from view: UIView) {
        PHPlayer.play("correct", ofType: "mp3")
        
        Timer.scheduleAfter(1.0, addToArray: &self.timers) {
            self.currentWord?.playAudio()
        }
        
        Timer.scheduleAfter(2.0, addToArray: &self.timers) {
            self.setupForNewWord()
        }
    }
    
    func userSelectedIncorrectWord(_ word: SightWord, from view: UIView) {
        shakeView(view)
        word.playAudio()
        
        UIView.animate(withDuration: 0.4, delay: 0.75, options: [], animations: {
            view.alpha = 0.4
        }, completion: nil)
    }
    
    @IBAction func repeatTapped(_ sender: Any) {
        self.animateForCurrentWord()
    }
    
    
    //MARK: Interactive Growing
    
    override func interactiveGrowScaleFor(_ view: UIView) -> CGFloat {
        return 1.075
    }
    
    override func totalDurationForInterruptedAnimationOn(_ view: UIView) -> TimeInterval? {
        let selectedText = (view.subviews.first as? UILabel)?.text
        return (selectedText == self.currentWord?.text) ? 2.0 : 0.75
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
