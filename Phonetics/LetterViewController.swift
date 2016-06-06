//
//  LetterViewController.swift
//  Phonetics
//
//  Created by Cal on 6/5/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class LetterViewController : UIViewController {
    
    var previousLetter: String? {
        let prev = PHLetters.indexOf(letter)!.predecessor()
        return prev >= 0 ? PHLetters[prev] : nil
    }
    
    var letter: String!
    
    var nextLetter: String? {
        let next = PHLetters.indexOf(letter)!.successor()
        return next < PHLetters.count ? PHLetters[next] : nil
    }
    
    
    //MARK: - Presentation
    
    static func presentForLetter(letter: String, inController other: UIViewController) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("letter") as! LetterViewController
        controller.letter = letter
        other.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Set up
    
    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var previousLetterButton: UIButton!
    @IBOutlet weak var nextLetterButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        decorateForCurrentLetter()
    }
    
    func decorateForCurrentLetter() {
        self.letterLabel.text = "\(letter)\(letter.lowercaseString)"
        self.previousLetterButton.enabled = previousLetter != nil
        self.nextLetterButton.enabled = nextLetter != nil
        
        let audio = "letter-\(letter)"
        PHPlayer.play(audio, ofType: "mp3")
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func backPressed(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func previousLetterPressed(sender: AnyObject) {
        letter = previousLetter ?? letter
        decorateForCurrentLetter()
    }
    
    @IBAction func nextLetterPressed(sender: AnyObject) {
        letter = nextLetter ?? letter
        decorateForCurrentLetter()
    }
}
