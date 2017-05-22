//
//  SightWord.swift
//  Phonics
//
//  Created by Cal Stephens on 5/21/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import Foundation
import AVFoundation

struct SightWord : Equatable {
    
    var text: String
    var sentence1: Sentence
    var sentence2: Sentence
    
    func playAudio() {
        PHPlayer.play(sentence2.audioFileName, ofType: "mp3", ifConcurrent: .interrupt,
                      startTime: 0.0,
                      endAfter: 0.465,
                      endWithFade: true,
                      fadeDuration: 0.2)
    }

}

func ==(left: SightWord, right: SightWord) -> Bool {
    return left.text == right.text
}
