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
    
    subscript(soundId: String) -> Sound! {
        return sounds.filter{ $0.soundId == soundId }.first
    }
    
    var isComplete: Bool {
        for sound in sounds {
            if !sound.puzzleIsComplete {
                return false
            }
        }
        
        return true
    }
    
    var icon: UIImage {
        return UIImage(named: "letter-icon-\(text.lowercased()).jpg")!
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
