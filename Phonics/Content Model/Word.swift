//
//  Word.swift
//  Phonetics
//
//  Created by Cal on 6/30/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct Word: Equatable {
    
    let text: String
    let pronunciation: String?
    let timedAudioInfo: AudioInfo?
    
    var audioInfo: AudioInfo? {
        if let timedAudioInfo = self.timedAudioInfo {
            return timedAudioInfo
        }
        
        let possibleStandaloneFile = "Words/\(text)"
        if Bundle.phonicsBundle?.url(forResource: possibleStandaloneFile, withExtension: "mp3") != nil {
            let length = UALengthOfFile("Words/\(text)", ofType: "mp3")
            return (fileName: possibleStandaloneFile, wordStart: 0, wordDuration: length)
        }
        
        return nil
    }
    
    var image: UIImage? {
        return UIImage(named: "\(text).jpg")
    }
    
    init?(text wordText: String?, pronunciation: String?, timedAudioInfo: AudioInfo?) {
        guard let wordText = wordText else { return nil }
        let text = wordText.lowercased().trimmingWhitespace()
        
        self.text = text
        self.pronunciation = pronunciation
        self.timedAudioInfo = timedAudioInfo
    }
    
    
    func attributedText(forSound sound: Sound, ofLetter letter: Letter) -> NSAttributedString {
        
        // [Word : OccurenceOfSoundToExclude]
        let explicitExclusions: [String : [Int]] = [
            "eagle" : [2],
            "skis" : [1],
            "footstool" : [2],
            "dune buggy" : [2],
            "ice cream" : [2],
            "excavator" : [2],
            "balance beam" : [1, 3],
            "tricycle" : [2],
            "unicycle" : [2],
            "motorcycle" : [2],
            "pretzel" : [2],
            "robot" : [2],
            "volcano" : [1],
            "seagulls" : [2]
        ]
        //balance beam
        var soundText = sound.displayString
        if soundText.hasPrefix("\(letter.text)\(letter.text.lowercased())") {
            soundText = letter.text
        }
        
        soundText = soundText.lowercased()
        
        var wordText = self.text.lowercased()
        
        if wordText == "saint bernard" {
            wordText = "Saint Bernard"
        }
        
        var mutableWord = wordText
        let attributedWord = NSMutableAttributedString(
            string: wordText,
            attributes: [.foregroundColor : UIColor.black])
        let matchColor = UIColor(hue: 0.00833, saturation: 0.9, brightness: 0.79, alpha: 1.0)
        
        var matchIndex = 1
        
        while mutableWord.contains(soundText) {
            let range = (mutableWord as NSString).range(of: soundText)
            if let exlusion = explicitExclusions[wordText] {
                if !exlusion.contains(matchIndex) {
                    attributedWord.addAttributes([NSAttributedStringKey.foregroundColor : matchColor], range: range)
                }
            } else {
                attributedWord.addAttributes([NSAttributedStringKey.foregroundColor : matchColor], range: range)
            }
            
            let replacement = String(repeating: "_", count: soundText.length)
            mutableWord = (mutableWord as NSString).replacingCharacters(in: range, with: replacement)
            matchIndex += 1
        }
        
        return attributedWord
    }
    
    
    func playAudio(withConcurrencyMode concurrencyMode: UAConcurrentAudioMode = .interrupt) {
        if let audioInfo = audioInfo {
            PHContent.playAudioForInfo(audioInfo, concurrentcyMode: concurrencyMode)
        } else {
            print("NO AUDIO FOR \(self.text)")
        }
    }
    
    
    //use wordsapi.com to fetch an IPA pronunciation of the word
    //requires an API key & a freemium payment plan
    func fetchPronunciation(withKey key: String, completion: @escaping (String?) -> ()) {
        let method = "https://wordsapiv1.p.mashape.com/words/\(self.text.preparedForURL())/pronunciation"
        var request = URLRequest(url: URL(string: method)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 1.0)
        request.setValue(key, forHTTPHeaderField: "X-Mashape-Key")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                if let subdict = dict["pronunciation"] as? NSDictionary {
                    if let pronunciation = subdict["all"] as? String {
                        completion(pronunciation)
                        return
                    }
                }
                
                completion(nil)
            }
            
            catch {
                completion(nil)
            }
            
        }.resume()
    }
    
    func printAudioTimings() {
        guard let url = Bundle.main.url(forResource: "Words/\(text)", withExtension: "mp3") else { return }
        guard let audioFile = try? AVAudioFile(forReading: url) else { return }
        
        //get raw data for sounds
        guard let buf = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: 900000) else { return }
        try? audioFile.read(into: buf)
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
        
        if ranges.count > 1 || ranges.count == 0 {
            //print("LITTLE PROBLEM with \(self.text)")
        }
        
        else {
            let current = ("\(ranges[0].start)" as NSString).substring(to: min(6, "\(ranges[0].start)".length))
            let duration = ("\(ranges[0].duration)" as NSString).substring(to: min(6, "\(ranges[0].duration)".length))
            print("\("Words/\(text)"),\(text)=\(current)/\(duration)")
        }
        
        /*var csvLine = "\(self.audioName(withWords: true)),"
        
        for i in 0..<spokenWords.count {
         
        }
        
        //print without the last ", "
        print(csvLine.substring(to: csvLine.index(csvLine.endIndex, offsetBy: -2)))*/
    }
    
}

func ==(left: Word, right: Word) -> Bool {
    return left.text == right.text
}
