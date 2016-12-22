//
//  Player.swift
//  Phonics
//
//  Created by Cal Stephens on 12/22/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation

class Player : NSCoding {
    
    static var current = Player()
    
    
    //MARK: Properties
    
    var puzzleProgress: [String : PuzzleProgress]
    
    init() {
        self.puzzleProgress = [:]
    }
    
    
    //MARK: - NSCoding
    
    private enum Key: String, NSCodingKey {
        case puzzleProgress = "Player.puzzleProgress"
    }
    
    required init?(coder decoder: NSCoder) {
        self.puzzleProgress = (decoder.value(forKey: Key.puzzleProgress) as? [String : PuzzleProgress]) ?? [:]
    }
    
    func encode(with encoder: NSCoder) {
        encoder.setValue(self.puzzleProgress, forKey: Key.puzzleProgress)
    }
    
}
