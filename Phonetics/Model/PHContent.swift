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
typealias AudioInfo = (fileName: String, wordStart: Double, wordDuration: Double)

class PHContentManager {
    
    let letters: [String : Letter]
    
    init() {
        
        //***
        //parse audio timings
        //***
        let audioFile = NSBundle.mainBundle().pathForResource("Audio Timings", ofType: "csv")!
        let audioText = try! NSString(contentsOfFile: audioFile, encoding: NSUTF8StringEncoding)
        let audioLines = audioText.componentsSeparatedByString("\r\n")
        
        var audioTimings = [FileName : [WordName : AudioInfo]]()
        
        for line in audioLines {
            let cols = line.componentsSeparatedByString(",")
            let fileName = cols[0]
            var wordsDict = [WordName : AudioInfo]()
            
            for i in 1 ..< cols.count {
                let splitSet = NSCharacterSet(charactersInString: "=/")
                let parts = cols[i].componentsSeparatedByCharactersInSet(splitSet)
                let value = (fileName: fileName,
                             wordStart: parts[1].asDouble()!,
                             wordDuration: parts[2].asDouble()!)
                wordsDict[parts[0]] = value
            }
            
            audioTimings[fileName] = wordsDict
        }
        
        
        //***
        //parse audio timings
        //***
        let pronunciationFile = NSBundle.mainBundle().pathForResource("Pronunciations", ofType: "txt")!
        let pronunciationText = try! NSString(contentsOfFile: pronunciationFile, encoding: NSUTF8StringEncoding)
        let pronunciationLines = pronunciationText.componentsSeparatedByString("\n")
        
        var pronunciations = [WordName : Pronunciation]()
        
        for line in pronunciationLines {
            if line.isEmpty || line.isWhitespace() { continue }
            let components = line.componentsSeparatedByString("=")
            
            let word = components[0]
            let pronunciation = components[1]
            pronunciations[word] = pronunciation
        }
        
        
        //**
        //now parse the actual content
        //**
        let file = NSBundle.mainBundle().pathForResource("Phonics Map", ofType: "csv")!
        let text = try! NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding)
        let lines = text.componentsSeparatedByString("\r\n")
        
        //put each line in a bucket for its letter
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
                let pronunciation = line[1]
                let displayString = line[5]
                let soundInfo = audioTimings["words-\(letter)-\(pronunciation)"] ?? [:]
                
                let words = [
                    Word(text: line[2], pronunciation: pronunciations[line[2].lowercaseString], audioInfo: soundInfo[line[2].lowercaseString]),
                    Word(text: line[3], pronunciation: pronunciations[line[3].lowercaseString], audioInfo: soundInfo[line[3].lowercaseString]),
                    Word(text: line[4], pronunciation: pronunciations[line[4].lowercaseString], audioInfo: soundInfo[line[4].lowercaseString])]
                .flatMap{ $0 }
                
                let sound = Sound(sourceLetter: letter,
                                  pronunciation: pronunciation,
                                  displayString: displayString,
                                  words: words,
                                  sourceLetterTiming: soundInfo[letter],
                                  pronunciationTiming: soundInfo[pronunciation])
                
                sounds.append(sound)
            }
            
            sounds.sortInPlace({ (sound1, sound2) in
                //single letters with source letter (A a ape tail jay) come first
                if sound1.sourceLetterTiming != nil { return true }
                if sound2.sourceLetterTiming != nil { return false }
                
                //single letters without source letter (uh canoe zebra sofa) come next
                let AaFormatted = "\(letter.uppercaseString)\(letter.lowercaseString)"
                if sound1.displayString == AaFormatted { return true }
                if sound2.displayString == AaFormatted { return false }
                
                //sort based on the characters of the two strings
                //replace the primary letter with "0" because Character("0") < Character("a" - "z") is TRUE
                //so the primary letter always comes first
                let sortable1 = sound1.displayString.lowercaseString.stringByReplacingOccurrencesOfString(letter.lowercaseString, withString: "0")
                let sortable2 = sound2.displayString.lowercaseString.stringByReplacingOccurrencesOfString(letter.lowercaseString, withString: "0")
                
                //sort two-letter based on non-primary character
                func checkCharactersAtIndex(index: Int, are check: (Character, Character) -> Bool) -> Bool {
                    let char1 = sortable1.stringAtIndex(index).characters.first!
                    let char2 = sortable2.stringAtIndex(index).characters.first!
                    return check(char1, char2)
                }
                
                //order: ab ac ad
                if checkCharactersAtIndex(0, are: ==) {
                    return checkCharactersAtIndex(1, are: <)
                }
                
                //order: ba ca da
                else {
                    return checkCharactersAtIndex(0, are: <)
                }
                
            })
            
            letters[letter] = Letter(text: letter, sounds: sounds)
        }
        
        self.letters = letters
        
        //print all audio timings
        //self.letters.values.forEach{ $0.sounds.forEach { $0.printAudioTimings() } }
    }
    
    
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
            for word in sound.words {
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
