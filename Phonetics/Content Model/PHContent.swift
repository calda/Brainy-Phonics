//
//  PHContent.swift
//  Phonetics
//
//  Created by Cal on 6/7/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit
import AVFoundation

let PHLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
let PHContent = PHContentManager()

typealias FileName = String
typealias WordName = String
typealias Pronunciation = String

class PHContentManager {
    
    let letters: [String : Letter]
    
    
    //MARK: - Static Init Helpers
    
    static func parsePronunciations() -> [WordName : Pronunciation]! {
        guard let pronunciationLines = linesForFile("Pronunciations", ofType:"txt", usingNewlineMarker:"\n") else { return nil }
        var pronunciations = [WordName : Pronunciation]()
        
        for line in pronunciationLines {
            if line.isEmpty || line.isWhitespace() { continue }
            let components = line.componentsSeparatedByString("=")
            
            let word = components[0]
            let pronunciation = components[1]
            pronunciations[word] = pronunciation
        }
        
        return pronunciations
    }
    
    static func parseLetters(pronunciations pronunciations: [WordName : Pronunciation]) -> [String : Letter]! {
        guard let letterLines = linesForCSV("Sound List") else { return nil }
        
        //put each line in a bucket for its letter
        var linesPerLetter = [String : [[String]]]()
        
        for line in letterLines {
            let letter = line[0]
            var currentLetterArray = linesPerLetter[letter] ?? []
            currentLetterArray.append(line)
            linesPerLetter[letter] = currentLetterArray
        }
        
        var letters = [String : Letter]()
        
        //process each line in context of the correct letter
        for letter in PHLetters {
            let lines = linesPerLetter[letter]!
            var sounds = [Sound]()
            
            for line in lines {
                let soundId = line[1]
                let displayString = line[2]
                let ipaPronunciation = displayString.lowercaseString //TODO: fix IPA pronunciations
                
                func wordForString(text: String) -> Word? {
                    return Word(text:text, pronunciation: pronunciations[text])
                }
                
                let primaryWords = [line[3], line[4], line[5]].flatMap{ wordForString($0) }
                
                var quizWords = [Word]()
                let quizWordsString = line[6]
                if !quizWordsString.isEmpty && !quizWordsString.isWhitespace() {
                    let quizWordsArray = quizWordsString.componentsSeparatedByString(",")
                    quizWords = quizWordsArray.flatMap{ wordForString($0.trimmingWhitespace()) }
                }
                
                let sound = Sound(sourceLetter: letter,
                                  soundId: soundId,
                                  ipaPronunciation: ipaPronunciation,
                                  displayString: displayString,
                                  primaryWords: primaryWords,
                                  quizWords: quizWords)
                
                sounds.append(sound)
            }
            
            letters[letter] = Letter(text: letter, sounds: sounds)
        }
        
        return letters
    }
    
    
    //MARK: - Initialization
    
    init() {
        let pronunciations = PHContentManager.parsePronunciations()
        self.letters = PHContentManager.parseLetters(pronunciations: pronunciations)
    }
    
    
    //MARK: - Accessors
    
    subscript(string: String) -> Letter! {
        return letters[string]
    }
    
    var allSounds: [Sound] {
        var sounds = [Sound]()
        
        for letter in letters.values {
            for sound in letter.sounds {
                sounds.append(sound)
            }
        }
        
        return sounds
    }
    
    var allWords: [Word] {
        var words = [Word]()
        
        for sound in allSounds {
            for word in sound.allWords {
                words.append(word)
            }
        }
        
        return words
    }
    
    var allWordsNoDuplicates: [Word] {
        var noDuplicates = [Word]()
        
        for word in allWords {
            if !noDuplicates.contains(word) {
                noDuplicates.append(word)
            }
        }
        
        return noDuplicates
    }

}
