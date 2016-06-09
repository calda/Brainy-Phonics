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
    @IBOutlet weak var previousLetterButton: UIButton!
    @IBOutlet weak var nextLetterButton: UIButton!
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
    
    var sound: Sound {
        return letter.sounds[0]
    }
    
    var previousLetter: Letter? {
        let prev = PHLetters.indexOf(letter.text)!.predecessor()
        if prev < 0 { return nil }
        return PHContent[PHLetters[prev]]
    }
    
    var nextLetter: Letter? {
        let next = PHLetters.indexOf(letter.text)!.successor()
        if next >= PHLetters.count { return nil }
        return PHContent[PHLetters[next]]
    }
    
    
    //MARK: - Presentation
    
    static func presentForLetter(letter: String, inController other: UIViewController) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("letter") as! LetterViewController
        controller.letter = PHContent[letter]!
        other.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Set up
    
    override func viewWillAppear(animated: Bool) {
        decorateForCurrentLetter()
    }
    
    func decorateForCurrentLetter(withAnimation animate: Bool = false, animationSubtype: String? = nil) {
        self.letterLabel.text = "\(letter.text)\(letter.text.lowercaseString)"
        self.previousLetterButton.enabled = previousLetter != nil
        self.nextLetterButton.enabled = nextLetter != nil
        
        for wordNumber in (1...3) {
            
            let (label, imageView) = labelAndImageForWord(wordNumber)
            
            if sound.words.count < wordNumber {
                label.text = nil
                imageView.image = nil
                continue
            }
            
            let word = sound.words[wordNumber - 1]
            
            var soundText = sound.displayString
            if soundText == "\(letter.text)\(letter.text.lowercaseString)" {
                soundText = letter.text.lowercaseString
            }
            
            let wordText = word.text.lowercaseString
            let attributedWord = NSMutableAttributedString(string: wordText, attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
            
            var range = (wordText as NSString).rangeOfString(soundText)
            let doubleRange = (wordText as NSString).rangeOfString("\(soundText)\(soundText)")
            if doubleRange.location != NSNotFound {
                range = doubleRange
            }
            
            let color = UIColor(hue: 0.00833, saturation: 0.9, brightness: 0.79, alpha: 1.0)
            
            if range.location != NSNotFound {
                attributedWord.addAttributes([NSForegroundColorAttributeName : color], range: range)
            }
            
            label.attributedText = attributedWord
            imageView.image = word.image
        }
        
        delay(0.4) {
            //self.letter.sounds[0].playAudio(withWords: true)
            PHPlayer.play("words-\(self.letter.text)", ofType: "mp3")
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
    
    @IBAction func previousLetterPressed(sender: AnyObject) {
        letter = previousLetter ?? letter
        decorateForCurrentLetter(withAnimation: true, animationSubtype: kCATransitionFromLeft)
    }
    
    @IBAction func nextLetterPressed(sender: AnyObject) {
        letter = nextLetter ?? letter
        decorateForCurrentLetter(withAnimation: true, animationSubtype: kCATransitionFromRight)
    }
}
