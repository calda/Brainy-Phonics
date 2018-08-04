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
            
            enum LabelPriority: Float {
                case show = 950
                case hide = 500
            }
            
            let priority: LabelPriority = showingText ? .show : .hide
            labelBottom.priority = UILayoutPriority(
                rawValue: priority.rawValue)
            
            self.label.superview?.layoutIfNeeded()
            self.label.alpha = showingText ? 1.0 : 0.0
            let scale: CGFloat = (showingText) ? 1.0 : 0.4
            label.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func setShowingText(_ showingText: Bool, animated: Bool, duration: TimeInterval? = 0.5) {
        
        if let duration = duration, animated {
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8) {
                self.showingText = showingText
            }
        } else {
            self.showingText = showingText
        }
        
    }
    
    
    //MARK: - View Configuration
    
    override func nibName() -> String {
        return "WordView"
    }
    
    func useWord(_ word: Word?, forSound sound: Sound? = nil, ofLetter letter: Letter? = nil) {
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
        
        //bump up the font size a bit on iPad (the attributed text doesn't seem to respond correctly to size classes)
        if iPad() {
            if let text = self.label.attributedText?.mutableCopy() as? NSMutableAttributedString {
                let fullRange = NSMakeRange(0, text.length)
                text.addAttributes(
                    [.font: self.label.font.withSize(35)],
                    range: fullRange)
                self.label.attributedText = text
            }
        }
    }
    
}
