//
//  Player.swift
//  Phonics
//
//  Created by Cal Stephens on 12/22/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation

let PHDefaultPlayerKey = "defaultPlayer"

class Player : NSObject, NSCoding {
    
    static var current = Player.load(id: PHDefaultPlayerKey) ?? Player()
    
    
    //MARK: Properties
    
    var id: String
    var puzzleProgress: [String : PuzzleProgress]
    
    override init() {
        self.id = PHDefaultPlayerKey
        self.puzzleProgress = [:]
    }
    
    
    //MARK: - NSCoding
    
    private enum Key: String, NSCodingKey {
        case id = "Player.id"
        case puzzleProgress = "Player.puzzleProgress"
    }
    
    required init?(coder decoder: NSCoder) {
        guard let id = (decoder.value(forKey: Key.id) as? String) else { return nil }
        self.id = id
        
        self.puzzleProgress = (decoder.value(forKey: Key.puzzleProgress) as? [String : PuzzleProgress]) ?? [:]
    }
    
    func encode(with encoder: NSCoder) {
        encoder.setValue(self.id, for: Key.id)
        encoder.setValue(self.puzzleProgress, for: Key.puzzleProgress)
    }
    
    
    //MARK: - Persistence
    
    func save() {
        UserDefaults.standard.setCodedObject(self, forKey: "player.\(self.id)")
    }
    
    static func load(id: String) -> Player? {
        return UserDefaults.standard.codedObjectForKey("player.\(id)") as? Player
    }
    
}
