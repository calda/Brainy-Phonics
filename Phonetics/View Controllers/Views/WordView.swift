//
//  WordView.swift
//  Phonetics
//
//  Created by Cal on 7/3/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

@IBDesignable
class WordView : UINibView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelBottom: NSLayoutConstraint!
    var word: Word?
    
    
    //MARK: - IBInspectables
    
    ///primarily for IBInspectable support. See useWord(...)
    @IBInspectable var image: UIImage! {
        didSet {
            self.imageView.image = image
        }
    }
    
    ///primarily for IBInspectable support. See useWord(...)
    @IBInspectable var text: String! {
        didSet {
            self.label.text = text
        }
    }
    
    @IBInspectable var showingText: Bool = true {
        didSet {
            labelBottom.constant = (showingText) ? 0 : -label.frame.height
            self.label.superview!.layoutIfNeeded()
            self.label.alpha = showingText ? 1.0 : 0.0
            let scale: CGFloat = (showingText) ? 1.0 : 0.4
            label.transform = CGAffineTransformMakeScale(scale, scale)
        }
    }
    
    func setShowingText(showingText: Bool, animated: Bool) {
        
        if (animated) {
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8) {
                self.showingText = showingText
            }
        }
        
        else {
            self.showingText = showingText
        }
        
    }
    
    
    //MARK: - View Configuration
    
    override func nibName() -> String {
        return "WordView"
    }
    
    func useWord(word: Word?, forSound sound: Sound? = nil, ofLetter letter: Letter? = nil) {
        self.word = word
        
        guard let word = word else {
            self.text = nil
            self.image = nil
            return
        }
        
        self.imageView.image = word.image
        self.text = word.text
        
        if let sound = sound, let letter = letter {
            self.label.attributedText = word.attributedText(forSound: sound, ofLetter: letter)
        }
    }
    
    
    //MARK: - User Interaction
    
    var tapInside = false
    @IBAction func touchEventReceived(sender: UIGestureRecognizer) {
        
    }
    
}
