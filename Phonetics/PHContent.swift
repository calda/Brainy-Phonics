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
        
        //**
        //now parse the actual content
        //**
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
                let pronunciation = line[1]
                let displayString = line[5]
                let soundInfo = audioTimings["words-\(letter)-\(pronunciation)"] ?? [:]
                
                let words = [
                    Word(text: line[2], audioInfo: soundInfo[line[2].lowercaseString]),
                    Word(text: line[3], audioInfo: soundInfo[line[3].lowercaseString]),
                    Word(text: line[4], audioInfo: soundInfo[line[4].lowercaseString])]
                .flatMap{ $0 }
                
                let sound = Sound(sourceLetter: letter,
                                  pronunciation: pronunciation,
                                  displayString: displayString,
                                  words: words,
                                  sourceLetterTiming: soundInfo[letter],
                                  pronunciationTiming: soundInfo[pronunciation]!)
                
                sounds.append(sound)
            }
            
            sounds.sortInPlace({ (sound1, sound2) in
                if sound1.sourceLetterTiming != nil { return true }
                if sound2.sourceLetterTiming != nil { return false }
                
                let AaFormatted = "\(letter.uppercaseString)\(letter.lowercaseString)"
                if sound1.displayString == AaFormatted { return true }
                if sound2.displayString == AaFormatted { return false }
                
                return true
            })
            
            letters[letter] = Letter(text: letter, sounds: sounds)
        }
        
        self.letters = letters
        
        //print all audio timings
        /*for letter in self.letters.values {
            for sound in letter.sounds {
                sound.printAudioTimings()
            }
        }*/
    }
    
    subscript(string: String) -> Letter? {
        return letters[string]
    }
    
}



//MARK: - Data Models

struct Letter: Equatable {
    
    let text: String
    let sounds: [Sound]
    
}

struct Sound: Equatable {
    
    let sourceLetter: String
    let pronunciation: String
    let displayString: String
    let words: [Word]
    
    var sourceLetterTiming: AudioInfo?
    var pronunciationTiming: AudioInfo
    
    func audioName(withWords withWords: Bool) -> String {
        return "\(withWords ? "words" : "sound")-\(sourceLetter)-\(pronunciation)"
    }
    
    func playAudio(withWords withWords: Bool) {
        let name = audioName(withWords: withWords)
        PHPlayer.play(name, ofType: "mp3")
    }
    
    func lengthForAudio(withWords withWords: Bool) -> NSTimeInterval {
        return UALengthOfFile(audioName(withWords: withWords), ofType: "mp3")
    }
    
    func printAudioTimings() {
        let url = NSBundle.mainBundle().URLForResource(self.audioName(withWords: true), withExtension: "mp3")
        
        let audioFile = try! AVAudioFile(forReading: url!)
        let format = AVAudioFormat(commonFormat: .PCMFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: 1, interleaved: false)
        
        //get raw data for sounds
        let buf = AVAudioPCMBuffer(PCMFormat: format, frameCapacity: 900000)
        try! audioFile.readIntoBuffer(buf)
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData[0], count:Int(buf.frameLength)))
        
        //average together 100 audio frames in little buckets
        var bucketArray = [Float]()
        for i in 0..<(floatArray.count / 100) {
            let start = i * 100;
            let end = start + 100;
            var sum: Float = 0.0
            
            for j in start..<end {
                sum += abs(floatArray[j])
            }
            
            bucketArray.append(sum / 100.0)
        }
        
        var ranges = [(start: Double, duration: Double)]()
        var currentStart: Int?
        var belowThresholdCount = 0
        
        //convert buckets to ranges using volume thresholds
        for i in 0..<bucketArray.count {
            
            if bucketArray[i] > 0.1 && currentStart == nil {
                currentStart = i * 100
                belowThresholdCount = 0
            }
                
            else if bucketArray[i] < 0.005 && currentStart != nil {
                belowThresholdCount += 1
                
                if belowThresholdCount == 350 || i == (bucketArray.count - 1) {
                    let currentEnd = (i - belowThresholdCount) * 100
                    ranges.append((Double(currentStart!) / audioFile.fileFormat.sampleRate, Double(currentEnd - currentStart!) / audioFile.fileFormat.sampleRate))
                    currentStart = nil
                }
            }
            
        }
        
        var spokenWords = [self.pronunciation]
        spokenWords.appendContentsOf(words.map({ $0.text }))
        //5 is format "A ah bat cat hat"
        if (ranges.count == 5) {
            spokenWords.insert(self.sourceLetter, atIndex: 0)
        }
        
        var csvLine = "\(self.audioName(withWords: true)),"
        
        for i in 0..<spokenWords.count {
            let current = ("\(ranges[i].start)" as NSString).substringToIndex(min(6, "\(ranges[i].start)".length))
            let duration = ("\(ranges[i].duration)" as NSString).substringToIndex(min(6, "\(ranges[i].duration)".length))
            csvLine += "\(spokenWords[i])=\(current)/\(duration),"
        }
        
        //print without the last ", "
        print(csvLine.substringToIndex(csvLine.endIndex.predecessor().predecessor()))
    }
    
}

struct Word: Equatable {
    
    let text: String
    let audioName: String
    let audioStartTime: Double
    let audioDuration: Double
    
    var image: UIImage {
        return UIImage(named: "\(text).jpg")!
    }
    
    func attributedText(forSound sound: Sound, ofLetter letter: Letter) -> NSAttributedString {
        
        var soundText = sound.displayString
        if soundText == "\(letter.text)\(letter.text.lowercaseString)" {
            soundText = letter.text
        }
        
        soundText = soundText.lowercaseString
        
        let wordText = self.text.lowercaseString
        var mutableWord = wordText
        let attributedWord = NSMutableAttributedString(string: wordText, attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
        let matchColor = UIColor(hue: 0.00833, saturation: 0.9, brightness: 0.79, alpha: 1.0)
        
        while mutableWord.containsString(soundText) {
            let range = (mutableWord as NSString).rangeOfString(soundText)
            attributedWord.addAttributes([NSForegroundColorAttributeName : matchColor], range: range)
            
            let replacement = String(count: soundText.length, repeatedValue: Character("_"))
            mutableWord = (mutableWord as NSString).stringByReplacingCharactersInRange(range, withString: replacement)
        }
        
        return attributedWord
    }
    
    init?(text wordText: String, audioInfo: AudioInfo?) {
        if wordText == "" {
            return nil
        }
        
        guard let audioInfo = audioInfo else {
            print("COULD NOT CREATE \(wordText)")
            return nil
        }
        
        var text = wordText.lowercaseString
        
        //remove padding spaces, if exist
        while text.hasPrefix(" ") {
            text = text.substringFromIndex(text.startIndex.successor())
        }
        
        while text.hasSuffix(" ") {
            text = text.substringToIndex(text.endIndex.predecessor())
        }
        
        self.text = text
        
        self.audioName = audioInfo.fileName
        self.audioStartTime = audioInfo.wordStart
        self.audioDuration = audioInfo.wordDuration
    }
    
}


//MARK: - Equatable conformance

func ==(left: Letter, right: Letter) -> Bool {
    return left.text == right.text
}

func ==(left: Sound, right: Sound) -> Bool {
    return left.pronunciation == right.pronunciation && left.sourceLetter == right.sourceLetter
}

func ==(left: Word, right: Word) -> Bool {
    return left.text == right.text
}
