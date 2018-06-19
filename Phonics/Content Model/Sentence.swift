//
//  Sentence.swift
//  Phonics
//
//  Created by Cal Stephens on 5/21/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import Foundation

public struct Sentence {
    
    var text: String
    var highlightWord: String
    
    var audioFileName: String
    var imageFileName: String
    
    
    var thumbnail: UIImage {

        if let thumbnail = UIImage.thumbnail(for: imageFileName) {
            return thumbnail
        }
        
        return UIImage(named: imageFileName)!
    }
    
    
    var image: UIImage {
        return UIImage(named: imageFileName)!
    }
    
    
    var attributedText: NSAttributedString {
        var processingSentence = self.text.lowercased()
        let matchWord = self.highlightWord.lowercased()
        let attributedSentence = NSMutableAttributedString(
                string: self.text,
                attributes: [.foregroundColor : UIColor.black])
        
        let matchColor = UIColor(hue: 0.00833, saturation: 0.9, brightness: 0.79, alpha: 1.0)
        
        func highlight(instancesOf matchString: String, locationOffset: Int, lengthOffset: Int) {
            while processingSentence.contains(matchString) {
                let range = (processingSentence as NSString).range(of: matchString)
                
                var rangeInActualSentence = NSMakeRange(range.location + locationOffset, range.length + lengthOffset)
                
                if rangeInActualSentence.location < 0 {
                    //happens sometimes in practice (ex: match is at index 0, location becomes -1)
                    let difference = -rangeInActualSentence.location
                    rangeInActualSentence = NSMakeRange(0, rangeInActualSentence.length - difference)
                }
                
                attributedSentence.addAttributes(
                    [.foregroundColor : matchColor],
                    range: rangeInActualSentence)
                
                let replacement = String(repeating: "_", count: matchString.length)
                processingSentence = (processingSentence as NSString).replacingCharacters(in: range, with: replacement)
            }
        }
        
        //pad with spaces so we can highlight instances of the word that start and end with spaces
        // AKA ignore instances of the word that are actually just parts of a larger word
        // also replace punctuation with spaces so they are ignored
        processingSentence = " " + processingSentence + " "
        for punctuation in [".", ",", "?", "!", "-"] {
            processingSentence = processingSentence.replacingOccurrences(of: punctuation, with: " ")
        }
        
        highlight(instancesOf: " " + matchWord + " ", locationOffset: -1, lengthOffset: -1)
        
        return attributedSentence
    }
    
    
}




