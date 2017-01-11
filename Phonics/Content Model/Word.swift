//
//  Word.swift
//  Phonetics
//
//  Created by Cal on 6/30/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit

struct Word: Equatable {
    
    let text: String
    let pronunciation: String?
    let audioInfo: AudioInfo?
    
    var image: UIImage? {
        return UIImage(named: "\(text).jpg")
    }
    
    init?(text wordText: String?, pronunciation: String?, audioInfo: AudioInfo?) {
        
        guard let wordText = wordText else { return nil }
        var text = wordText.lowercased()
        
        //remove padding spaces, if exist
        while text.hasPrefix(" ") {
            text = text.substring(from: text.characters.index(after: text.startIndex))
        }
        
        while text.hasSuffix(" ") {
            text = text.substring(to: text.characters.index(before: text.endIndex))
        }
        
        self.text = text
        self.pronunciation = pronunciation
        self.audioInfo = audioInfo
    }
    
    
    func attributedText(forSound sound: Sound, ofLetter letter: Letter) -> NSAttributedString {
        
        // [Word : OccurenceOfSoundToExclude]
        let explicitExclusions: [String : Int] = [
            "eagle" : 2,
            "skis" : 1,
            "volcano" : 1
        ]
        
        var soundText = sound.displayString
        if soundText.hasPrefix("\(letter.text)\(letter.text.lowercased())") {
            soundText = letter.text
        }
        
        soundText = soundText.lowercased()
        
        let wordText = self.text.lowercased()
        var mutableWord = wordText
        let attributedWord = NSMutableAttributedString(string: wordText, attributes: [NSForegroundColorAttributeName : UIColor.black])
        let matchColor = UIColor(hue: 0.00833, saturation: 0.9, brightness: 0.79, alpha: 1.0)
        
        var matchIndex = 1
        
        while mutableWord.contains(soundText) {
            let range = (mutableWord as NSString).range(of: soundText)
            if (explicitExclusions[wordText] != matchIndex) {
                attributedWord.addAttributes([NSForegroundColorAttributeName : matchColor], range: range)
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
    
}

func ==(left: Word, right: Word) -> Bool {
    return left.text == right.text
}
