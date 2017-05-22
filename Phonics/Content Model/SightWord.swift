//
//  SightWord.swift
//  Phonics
//
//  Created by Cal Stephens on 5/21/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import Foundation
import AVFoundation

struct SightWord {
    
    var text: String
    var sentence1: Sentence
    var sentence2: Sentence
    
    private var audioInfo: AudioInfo {
        //FYI: PHContent.play(...) plays 0.5 seconds more than the provided duration
        return (fileName: sentence1.audioFileName, wordStart: 0, wordDuration: 0.05)
    }
    
    func playAudio() {
        PHPlayer.play(sentence1.audioFileName, ofType: "mp3", ifConcurrent: .interrupt,
                      startTime: 0.0,
                      endAfter: 0.465,
                      endWithFade: true,
                      fadeDuration: 0.2)
    }

}
