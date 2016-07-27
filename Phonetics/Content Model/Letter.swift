//
//  Letter.swift
//  Phonetics
//
//  Created by Cal on 6/30/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

struct Letter: Equatable {
    
    let text: String
    let sounds: [Sound]
    
    subscript(sound: String) -> Sound! {
        return sounds.filter{ $0.alphabetPronunciation == sound }.first
    }
    
    func playSound() {
        var info: AudioInfo?
        
        sounds.forEach{ word in
            if let timing = word.sourceLetterTiming {
                info = timing
            }
        }
        
        if let info = info {
            PHContent.playAudioForInfo(info)
        }
    }
    
}

func ==(left: Letter, right: Letter) -> Bool {
    return left.text == right.text
}