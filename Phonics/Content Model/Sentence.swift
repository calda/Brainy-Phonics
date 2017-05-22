//
//  Sentence.swift
//  Phonics
//
//  Created by Cal Stephens on 5/21/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import Foundation

struct Sentence {
    
    var text: String
    var highlightWord: String
    
    var audioFileName: String
    var imageFileName: String
    
    var image: UIImage {
        return UIImage(named: imageFileName)!
    }
    
    var attributedText: NSAttributedString {
        
        var lowercaseSentence = self.text.lowercased()
        let matchWord = self.highlightWord.lowercased()
        let attributedSentence = NSMutableAttributedString(string: self.text,
                                                           attributes: [NSForegroundColorAttributeName : UIColor.black])
        
        let matchColor = UIColor(hue: 0.00833, saturation: 0.9, brightness: 0.79, alpha: 1.0)
        
        while lowercaseSentence.contains(matchWord) {
            let range = (lowercaseSentence as NSString).range(of: matchWord)
            attributedSentence.addAttributes([NSForegroundColorAttributeName : matchColor], range: range)
            
            let replacement = String(repeating: "_", count: matchWord.length)
            lowercaseSentence = (lowercaseSentence as NSString).replacingCharacters(in: range, with: replacement)
        }
        
        return attributedSentence
    }
    
}
