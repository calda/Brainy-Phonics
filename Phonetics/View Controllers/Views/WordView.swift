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
    
    @IBInspectable var showingText: Bool? {
        didSet {
            func transition() {
                labelBottom.constant = (showingText ?? true) ? -label.frame.height : 0
                self.nibView.layoutIfNeeded()
                let scale: CGFloat = (showingText ?? true) ? 1.0 : 0.001
                label.transform = CGAffineTransformMakeScale(scale, scale)
            }
            
            #if !TARGET_INTERFACE_BUILDER
                UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0) {
                    transition()
                }
            #else
                transition()
            #endif
        }
    }
    
    
    //MARK: - View Configuration
    
    override func nibName() -> String {
        return "WordView"
    }
    
    func useWord(word: Word?, forSound sound: Sound? = nil, ofLetter letter: Letter? = nil) {
        self.word = word
        
        guard let word = word else {
            self.imageView.image = nil
            self.label.text = nil
            return
        }
        
        self.imageView.image = word.image
        
        if let sound = sound, let letter = letter {
            self.label.attributedText = word.attributedText(forSound: sound, ofLetter: letter)
        } else {
            self.label.text = word.text
        }
    }
    
    
    //MARK: - User Interaction
    
    var tapInside = false
    @IBAction func touchEventReceived(sender: UIGestureRecognizer) {
        
    }
    
}
