//
//  UniversalAudioPlayer.swift
//  Rhyme a Zoo
//
//  Created by Cal on 6/29/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

var PHPlayer: UAPlayer {
    return UAPlayer()
}

private let UAAudioQueue = DispatchQueue(label: "com.hearatale.phonics.audio", attributes: [])
private var UAAudioIsPlaying = false
private var UAShouldHaltPlayback = false

enum UAConcurrentAudioMode {
    ///The audio track will immediately start playing.
    case interrupt
    ///The audio track will be added to the play queue and will attempt to play after other tracks finish playing.
    case wait
    ///The audio track will only play is no other audio is playing or queued.
    case ignore
}

func UAHaltPlayback() {
    UAShouldHaltPlayback = true
    UAAudioIsPlaying = false
    delay(0.05) {
        UAShouldHaltPlayback = false
    }
}

func UAIsAudioPlaying() -> Bool {
    return UAAudioIsPlaying
}

func UALengthOfFile(_ name: String, ofType type: String) -> TimeInterval {
    if let path = Bundle.main.path(forResource: name, ofType: type) {
        let URL = Foundation.URL(fileURLWithPath: path)
        let asset = AVURLAsset(url: URL, options: nil)
        
        let time = asset.duration
        return TimeInterval(CMTimeGetSeconds(time))
    }
    return 0.0
}

func UAFileExists(name: String, ofType type: String) -> Bool {
    let duration = UALengthOfFile(name, ofType: type)
    return (duration == 0 ? false : true)
}

func UAWhenDonePlayingAudio(_ block: @escaping () -> ()) {
    UAAudioQueue.async(execute: {
        while(UAIsAudioPlaying()) { }
        sync {
            block()
        }
    })
}

class UAPlayer {

    var player: AVAudioPlayer?
    var name: String?
    var shouldHalt = false
    var startTime: TimeInterval?
    var endAfter: TimeInterval?
    var endWithFade: Bool?
    var fadeDuration: TimeInterval?
    
    @discardableResult func play(_ name: String, ofType type: String,
              ifConcurrent mode: UAConcurrentAudioMode = .interrupt,
              startTime: TimeInterval = 0.0,
              endAfter: TimeInterval? = nil,
              endWithFade: Bool = false,
              fadeDuration: TimeInterval = 1.0) -> Bool {
        
        self.name = name
        self.startTime = startTime
        self.endAfter = endAfter
        self.endWithFade = endWithFade
        self.fadeDuration = fadeDuration
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        
        if let path = Bundle.main.path(forResource: name, ofType: type), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            
            do {
                player = try AVAudioPlayer(data: data, fileTypeHint: nil)
            } catch {
                return false
            }
            
            if mode == .interrupt {
                startPlayback()
                return true
            }
            
            if mode == .ignore {
                if !UAAudioIsPlaying {
                    startPlayback()
                    return true
                }
            }
            
            if mode == .wait {
                UAAudioQueue.async(execute: {
                    while(UAAudioIsPlaying) {
                        if UAShouldHaltPlayback {
                            return
                        }
                    }
                    self.startPlayback()
                })
                return true
            }
        }
        
        return false
    }
    
    func startPlayback() {
        if let player = player {
            UAAudioIsPlaying = true
            
            player.play()
            
            if let startTime = startTime, startTime != 0.0 {
                player.currentTime = startTime
            }
            
            if let endAfter = endAfter {
                
                delay(endAfter) {
                    
                    if self.endWithFade == true {
                        UAHaltPlayback()
                    } else {
                        player.stop()
                        UAAudioIsPlaying = false
                    }
                }
            }
            
            UAAudioQueue.async(execute: {
                while(player.isPlaying) {
                    if self.shouldHalt && !self.fading {
                        sync {
                            self.doVolumeFade()
                        }
                        return
                    }
                    if UAShouldHaltPlayback {
                        sync {
                            self.shouldHalt = true
                            UAAudioIsPlaying = false
                        }
                    }
                }
                
                if !self.shouldHalt {
                    sync {
                        UAAudioIsPlaying = false
                    }
                }
            })
        }
    }
    
    var fading = false
    
    func doVolumeFade() {
        fading = true
        if let player = player {
            if player.volume > 0.1 {
                player.volume = player.volume - 0.1
                delay(0.1 * (self.fadeDuration ?? 1.0)) {
                    self.doVolumeFade()
                }
            } else {
                fading = false
                player.stop()
            }
            
        }
    }
    
}
