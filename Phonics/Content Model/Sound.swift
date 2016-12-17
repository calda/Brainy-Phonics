//
//  Sound.swift
//  Phonetics
//
//  Created by Cal on 6/30/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct Sound: Equatable {
    
    
    //MARK: - Properties
    
    let sourceLetter: String
    let soundId: String
    let ipaPronunciation: String
    let displayString: String
    
    let primaryWords: [Word]
    let quizWords: [Word]
    
    var sourceLetterTiming: AudioInfo?
    var pronunciationTiming: AudioInfo?
    
    var allWords: [Word] {
        var words = primaryWords
        words.append(contentsOf: quizWords)
        return words
    }
    
    var puzzleImage: UIImage? {
        let name = "puzzle-\(sourceLetter)-\(soundId).jpg"
        return UIImage(named: name)
    }
    
    
    //MARK: - Helper Methods
    
    func audioName(withWords: Bool) -> String {
        return "\(withWords ? "words" : "sound")-\(sourceLetter)-\(soundId)"
    }
    
    func playAudio(withWords: Bool) {
        let name = audioName(withWords: withWords)
        PHPlayer.play(name, ofType: "mp3")
    }
    
    func lengthForAudio(withWords: Bool) -> TimeInterval {
        return UALengthOfFile(audioName(withWords: withWords), ofType: "mp3")
    }
    
    
    //MARK: - Data Generation
    
    func printAudioTimings() {
        let url = Bundle.main.url(forResource: self.audioName(withWords: true), withExtension: "mp3")
        
        let audioFile = try! AVAudioFile(forReading: url!)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: 1, interleaved: false)
        
        //get raw data for sounds
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 900000)
        try! audioFile.read(into: buf)
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        
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
        
        var spokenWords = [self.soundId]
        spokenWords.append(contentsOf: self.primaryWords.map({ $0.text }))
        //5 is format "A ah bat cat hat"
        if (ranges.count == 5) {
            spokenWords.insert(self.sourceLetter, at: 0)
        }
        
        var csvLine = "\(self.audioName(withWords: true)),"
        
        for i in 0..<spokenWords.count {
            let current = ("\(ranges[i].start)" as NSString).substring(to: min(6, "\(ranges[i].start)".length))
            let duration = ("\(ranges[i].duration)" as NSString).substring(to: min(6, "\(ranges[i].duration)".length))
            csvLine += "\(spokenWords[i])=\(current)/\(duration),"
        }
        
        //print without the last ", "
        print(csvLine.substring(to: csvLine.index(csvLine.endIndex, offsetBy: -2)))
    }
    
    //finds the longest common substring of the sound's words' IPA spellings
    //which should be the IPA representation of this sound
    //unfortunately our words are not precise enough to be 100%
    //IPA is hard
    func generatePronunciation() -> String {
        
        let pronunciations = self.primaryWords.flatMap{ $0.pronunciation }
        
        var common = pronunciations[0]
        for pronunciation in pronunciations {
            common = lComSubStr(common, pronunciation)
        }
        
        return common
        
    }
    
}

func ==(left: Sound, right: Sound) -> Bool {
    return left.soundId == right.soundId && left.sourceLetter == right.sourceLetter
}

