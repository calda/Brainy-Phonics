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
typealias SoundID = String
typealias Pronunciation = String
typealias AudioInfo = (fileName: String, wordStart: Double, wordDuration: Double)

class PHContentManager {
    
    let letters: [String : Letter]
    
    
    //MARK: - Static Init Helpers
    
    static func parseAudioTimings() -> [FileName : [WordName : AudioInfo]] {
        guard let audioLines = linesForCSV("Audio Timings") else { return [:] }
        var audioTimings = [FileName : [WordName : AudioInfo]]()
        
        for line in audioLines {
            let fileName = line[0]
            var wordsDict = [WordName : AudioInfo]()
            
            for i in 1 ..< line.count {
                let splitSet = CharacterSet(charactersIn: "=/")
                let parts = line[i].components(separatedBy: splitSet)
                let value = (fileName: fileName,
                             wordStart: parts[1].asDouble()!,
                             wordDuration: parts[2].asDouble()!)
                wordsDict[parts[0]] = value
            }
            
            audioTimings[fileName] = wordsDict
        }
        
        return audioTimings
    }
    
    static func parsePronunciationsFile(named name: String) -> [String : Pronunciation] {
        guard let pronunciationLines = linesForFile(name, ofType:"txt", usingNewlineMarker:"\n") else { return [:] }
        var pronunciations = [WordName : Pronunciation]()
        
        for line in pronunciationLines {
            if line.isEmpty || line.isWhitespace() { continue }
            let components = line.components(separatedBy: "=")
            
            let word = components[0]
            let pronunciation = components[1]
            if pronunciation.isEmpty || pronunciation.isWhitespace() { continue }
            
            pronunciations[word] = pronunciation
        }
        
        return pronunciations
    }
    
    static func parseLetters(audioTimings: [FileName : [WordName : AudioInfo]], wordPronunciations: [WordName : Pronunciation], soundPronunciations: [SoundID : Pronunciation]) -> [String : Letter] {
        guard let letterLines = linesForCSV("Sound List") else { return [:] }
        
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
                
                let globalIdentifier = "\(letter)-\(soundId)"
                let ipaPronunciation = soundPronunciations[globalIdentifier]
                let soundInfo = audioTimings["words-\(globalIdentifier)"] ?? [:]
                
                func wordForString(_ text: String) -> Word? {
                    return Word(text:text, pronunciation: wordPronunciations[text], timedAudioInfo: soundInfo[text])
                }
                
                let primaryWords = [line[3], line[4], line[5]].flatMap(wordForString)
                
                var quizWords = [Word]()
                let quizWordsString = line[6]
                if !quizWordsString.isEmpty && !quizWordsString.isWhitespace() {
                    let quizWordsArray = quizWordsString.components(separatedBy: ",")
                    quizWords = quizWordsArray.flatMap{ wordForString($0.trimmingWhitespace()) }
                }
                
                let sound = Sound(sourceLetter: letter,
                                  soundId: soundId,
                                  ipaPronunciation: ipaPronunciation,
                                  displayString: displayString,
                                  primaryWords: primaryWords,
                                  quizWords: quizWords,
                                  sourceLetterTiming: soundInfo[letter],
                                  pronunciationTiming: soundInfo[soundId])
                
                sounds.append(sound)
            }
            
            letters[letter] = Letter(text: letter, sounds: sounds)
        }
        
        return letters
    }
    
    
    //MARK: - Initialization
    
    init() {
        let audioTimings = PHContentManager.parseAudioTimings()
        let wordPronunciations = PHContentManager.parsePronunciationsFile(named: "Word Pronunciations")
        let soundPronunciations = PHContentManager.parsePronunciationsFile(named: "Sound Pronunciations")
        self.letters = PHContentManager.parseLetters(audioTimings: audioTimings,
                                                     wordPronunciations: wordPronunciations,
                                                     soundPronunciations: soundPronunciations)
    }
    
    
    //MARK: - Helper Funcitons
    
    ///plays the audio starting 0.3 seconds early and ending 0.5 seconds late to account for errors
    func playAudioForInfo(_ info: AudioInfo?, concurrentcyMode: UAConcurrentAudioMode = .interrupt) {
        guard let info = info else { return }
        
        PHPlayer.play(info.fileName, ofType: "mp3", ifConcurrent: concurrentcyMode,
                      startTime: max(0.0, info.wordStart - 0.3),
                      endAfter: info.wordDuration + 0.5)
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
    
    var allSoundsSorted: [Sound] {
        return self.allSounds.sorted(by: { left, right in
            return left.displayString.compare(right.displayString) == .orderedAscending
        })
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
