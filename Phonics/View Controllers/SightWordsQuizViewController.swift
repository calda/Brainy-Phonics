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
    static let chooseWord = InstructionsContent(text: "Choose the word", image: #imageLiteral(resourceName: "button-question-big"))
    static let correct = InstructionsContent(text: "Correct! Good job!", image: #imageLiteral(resourceName: "correct"))
    
    let text: String
    let image: UIImage
}

enum SightWordsQuizMode {
    case singleWord(SightWord)
    case allWords
    
    func allAvailableOptionWords(from sightWordsManager: SightWordsManager) -> [SightWord] {
        var words = sightWordsManager.words
        
        switch(self) {
        case .singleWord(let specificWord):
            if let indexOfSpecificWord = words.index(of: specificWord) {
                words.remove(at: indexOfSpecificWord)
            }
        case .allWords:
            break
        }
        
        return words
    }
    
    func selectNextAnswerWord(from availableWords: inout [SightWord]) -> SightWord? {
        switch(self) {
        case .singleWord(let specificWord):
            return specificWord
        case .allWords:
            return availableWords.popLast()
        }
    }
    
    func selectNextIncorrectWords(from availableWords: inout [SightWord]) -> [SightWord] {
        return [
            availableWords.popLast(),
            availableWords.popLast(),
            availableWords.popLast()
        ].flatMap{ $0 }
    }
    
}


class SightWordsQuizViewController : InteractiveGrowViewController {
    
    
    //MARK: - Presentation
    
    static let storyboardId = "sightWordsQuiz"
    
    static func present(from source: UIViewController, using sightWordsManager: SightWordsManager, mode: SightWordsQuizMode) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as! SightWordsQuizViewController
        controller.sightWordsManager = sightWordsManager
        controller.mode = mode
        source.present(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Setup
    
    var sightWordsManager: SightWordsManager!
    var mode: SightWordsQuizMode = .allWords
    var remainingWords: [SightWord] = []
    var currentWord: SightWord?
    var guessCount = 0
    
    var currentlyAnimating = false
    var timers = [Timer]()
    
    @IBOutlet var answerLabels: [UILabel]!
    var originalCenters = [UIView : CGPoint]()
    
    @IBOutlet weak var answersView: UIView!
    @IBOutlet weak var buttonArea: UIView!
    
    @IBOutlet weak var instructionsPill: UIView!
    @IBOutlet weak var instructionsImage: UIImageView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var bankButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        self.view.backgroundColor = sightWordsManager.category.color
        self.buttonArea.backgroundColor = sightWordsManager.category.color
        
        for label in answerLabels {
            guard let superview = label.superview else { continue }
            self.originalCenters[superview] = superview.center
        }
        
        self.updateInstructions(with: .listen, animate: false)
        self.setupForNewWord(animateTransition: false)
    }
    
    func setupForNewWord(animateTransition: Bool) {
        guessCount = 0
        
        if self.remainingWords.count < 4 {
            self.remainingWords = mode.allAvailableOptionWords(from: sightWordsManager).shuffled()
        }
        
        self.currentWord = mode.selectNextAnswerWord(from: &remainingWords)
        guard let currentWord = self.currentWord else { return }
        
        let incorrectWords = mode.selectNextIncorrectWords(from: &remainingWords)
        let wordsForQuizRound = [currentWord] + incorrectWords
        
        guard !SightWord.arrayHasHomophoneConflicts(wordsForQuizRound)
            && wordsForQuizRound.count == 4 else
        {
            setupForNewWord(animateTransition: animateTransition) //just try again -- this should be rare
            return
        }
        
        for (label, word) in zip(self.answerLabels, wordsForQuizRound.shuffled()) {
            label.text = word.text
            
            if let superview = label.superview {
                superview.alpha = 1.0
                superview.center = self.originalCenters[superview] ?? superview.center
            }
        }
        
        let animateForNewWord = {
            self.updateInstructions(with: .listen, animate: true)
            self.animateForCurrentWord()
        }
        
        if animateTransition {
            animateTransitionToNewWord(then: animateForNewWord)
        } else {
            animateForNewWord()
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
            self.currentWord?.playAudio(using: self.sightWordsManager)
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
            self.currentWord?.playAudio(using: self.sightWordsManager)
        }
        
        Timer.scheduleAfter(1.75, addToArray: &self.timers) {
            let selectedWordViewCenter = view.superview!.convert(view.center, to: self.view)
            self.playCoinAnimation(startingAt: selectedWordViewCenter)
        }
        
        Timer.scheduleAfter(3.0, addToArray: &self.timers) {
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
            self.currentWord?.playAudio(using: self.sightWordsManager)
        })
        
        Timer.scheduleAfter(0.5 + 0.1 + 1.0, addToArray: &self.timers, handler: {
            self.currentlyAnimating = false
        })
        
        Timer.scheduleAfter(0.5 + 0.1 + 1.5, addToArray: &self.timers, handler: {
            self.updateInstructions(with: .chooseWord, animate: true)
        })
        
    }
    
    func playCoinAnimation(startingAt origin: CGPoint) {
        var coinImage: UIImage?
        switch(self.guessCount) {
        case 1:
            coinImage = #imageLiteral(resourceName: "coin-gold")
            Player.current.sightWordCoins.gold += 1
        case 2:
            coinImage = #imageLiteral(resourceName: "coin-silver")
            Player.current.sightWordCoins.silver += 1
        default:
            coinImage = nil
        }
        
        if let coinImage = coinImage {
            
            //save new coin
            Player.current.save()
            
            let coinView = UIImageView(image: coinImage)
            coinView.frame.size = iPad() ? CGSize(width: 150, height: 150) : CGSize(width: 75, height: 75)
            coinView.center = origin
            coinView.alpha = 0.0
            self.view.addSubview(coinView)
            
            self.view.bringSubview(toFront: bankButton)
            
            //animate coin into piggy bank
            UIView.animate(withDuration: 0.1, animations: {
                coinView.alpha = 1.0
            })
            
            UIView.animate(withDuration: 0.55, delay: 0.0, usingSpringWithDamping: 1.0, animations: {
                coinView.frame.size = CGSize(width: 40, height: 40)
                coinView.center = self.bankButton.superview!.convert(self.bankButton.center, to: self.view)
            })
            
            //pulse piggybank
            UIView.animate(withDuration: 0.25, delay: 0.2, options: [.allowUserInteraction, .curveEaseInOut, .beginFromCurrentState], animations: {
                self.bankButton.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            }, completion: nil)
            
            UIView.animate(withDuration: 0.45, delay: 0.7, options: [.allowUserInteraction, .curveEaseInOut, .beginFromCurrentState], animations: {
                self.bankButton.transform = .identity
            }, completion: nil)
        }
    }
    
    //MARK: - User Interaction
    
    @IBAction func repeatTapped(_ sender: Any) {
        self.animateForCurrentWord()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bankButtonPressed(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        
        BankViewController.present(
            from: self,
            goldCount: Player.current.sightWordCoins.gold,
            silverCount: Player.current.sightWordCoins.silver,
            onDismiss: {
                self.view.isUserInteractionEnabled = true
                self.animateForCurrentWord()
        })
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
        
        guard let sightWord = sightWordsManager.words.first(where: { $0.text == selectedText }) else {
            return
        }
        
        guessCount += 1
        
        if sightWord == self.currentWord {
            userSelectedCorrectWord(from: view)
        } else {
            userSelectedIncorrectWord(sightWord, from: view)
        }
    }
    
}
