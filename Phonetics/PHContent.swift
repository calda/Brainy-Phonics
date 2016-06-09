//
//  PHContent.swift
//  Phonetics
//
//  Created by Cal on 6/7/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

let PHLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
let PHContent = PHContentManager()

class PHContentManager {
    
    let letters: [String : Letter]
    
    init() {
        
        let file = NSBundle.mainBundle().pathForResource("Phonics Map", ofType: "csv")!
        let text = try! NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding)
        let lines = text.componentsSeparatedByString("\r\n")
        
        //give each line to a letter
        var linesPerLetter = [String : [String]]()
        
        for line in lines {
            let cols = line.componentsSeparatedByString(",")
            let letter = cols[0]
            var currentLetterArray = linesPerLetter[letter] ?? []
            currentLetterArray.append(line)
            linesPerLetter[letter] = currentLetterArray
        }
        
        var letters = [String : Letter]()
        
        //process each line in context of the correct letter
        for letter in PHLetters {
            let lines = linesPerLetter[letter]!
            var sounds = [Sound]()
            
            for line in lines.map({ $0.componentsSeparatedByString(",") }) {
                let words = [Word(text: line[2]), Word(text: line[3]), Word(text: line[4])]
                
                for word in words {
                    if word.image == nil && word.text != "" {
                        print("MISSING IMAGE FOR \(word.text).jpg")
                    }
                }
                
                let sound = Sound(pronunciation: line[1], displayString: line[5], words: words)
                sounds.append(sound)
            }
            
            letters[letter] = Letter(text: letter, sounds: sounds)
        }
        
        self.letters = letters
    }
    
    subscript(string: String) -> Letter? {
        return letters[string]
    }
    
}


//MARK: - Data Models

struct Letter {
    
    let text: String
    let sounds: [Sound]
    
}

struct Sound {
    
    let pronunciation: String
    let displayString: String
    let words: [Word]
    
    func audioName(withWords withWords: Bool) -> String {
        return "\(withWords ? "words" : "sound")-\(pronunciation)"
    }
    
    func playAudio(withWords withWords: Bool) {
        let name = audioName(withWords: withWords)
        PHPlayer.play(name, ofType: "mp3")
    }
    
    func lengthForAudio(withWords withWords: Bool) -> NSTimeInterval {
        return UALengthOfFile(audioName(withWords: withWords), ofType: "mp3")
    }
    
}

struct Word {
    
    let text: String
    var image: UIImage? {
        return UIImage(named: "\(text).jpg")
    }
    
    init(text wordText: String) {
        var text = wordText.lowercaseString
        
        //remove padding spaces, if exist
        while text.hasPrefix(" ") {
            text = text.substringFromIndex(text.startIndex.successor())
        }
        
        while text.hasSuffix(" ") {
            text = text.substringToIndex(text.endIndex.predecessor())
        }
        
        self.text = text
    }
    
}
