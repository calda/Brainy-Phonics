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

private let UAAudioQueue = dispatch_queue_create("com.hearatale.phonetics.audio", DISPATCH_QUEUE_SERIAL)
private var UAAudioIsPlaying = false
private var UAShouldHaltPlayback = false

enum UAConcurrentAudioMode {
    ///The audio track will immediately start playing.
    case Interrupt
    ///The audio track will be added to the play queue and will attempt to play after other tracks finish playing.
    case Wait
    ///The audio track will only play is no other audio is playing or queued.
    case Ignore
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

func UALengthOfFile(name: String, ofType type: String) -> NSTimeInterval {
    if let path = NSBundle.mainBundle().pathForResource(name, ofType: type) {
        let URL = NSURL(fileURLWithPath: path)
        let asset = AVURLAsset(URL: URL, options: nil)
        
        let time = asset.duration
        return NSTimeInterval(CMTimeGetSeconds(time))
    }
    return 0.0
}

class UAPlayer {

    var player: AVAudioPlayer?
    var name: String?
    var shouldHalt = false
    
    func play(name: String, ofType type: String, ifConcurrent mode: UAConcurrentAudioMode = .Interrupt ) -> Bool {
        
        self.name = name
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
        
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: type) {
            let data = NSData(contentsOfFile: path)!
            
            player = try! AVAudioPlayer(data: data, fileTypeHint: nil)
            
            if mode == .Interrupt {
                startPlayback()
                return true
            }
            
            if mode == .Ignore {
                if !UAAudioIsPlaying {
                    startPlayback()
                    return true
                }
            }
            
            if mode == .Wait {
                dispatch_async(UAAudioQueue, {
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
            
            dispatch_async(UAAudioQueue, {
                while(player.playing) {
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
                delay(0.1) {
                    self.doVolumeFade()
                }
            } else {
                fading = false
                player.stop()
            }
            
        }
    }
    
}