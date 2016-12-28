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
        guard let id = (decoder.value(for: Key.id) as? String) else { return nil }
        self.id = id
        
        self.puzzleProgress = (decoder.value(for: Key.puzzleProgress) as? [String : PuzzleProgress]) ?? [:]
    }
    
    func encode(with encoder: NSCoder) {
        encoder.setValue(self.id, for: Key.id)
        encoder.setValue(self.puzzleProgress, for: Key.puzzleProgress)
    }
    
    
    //MARK: - Persistence
    
    func save() {
        
        let key = "player.\(id)"
        let defaults = UserDefaults.standard
        defaults.synchronize()
        
        defaults.set(true, forKey: "has been saved recently")
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self)
        print("saved \(encodedData)")
        defaults.set(encodedData, forKey: key)
        defaults.synchronize()
    }
    
    static func load(id: String) -> Player? {
        let key = "player.\(id)"
        let defaults = UserDefaults.standard
        defaults.synchronize()
        
        print("has been saved recently: \(defaults.bool(forKey: "has been saved recently"))")
        
        guard let data = defaults.data(forKey: key) else {
            print("NO DATA FOR \(key)")
            return nil
        }
        
        print("loaded \(data)")
        
        guard let player = NSKeyedUnarchiver.unarchiveObject(with: data) as? Player else {
            print("FAILED TO UNARCHIVE PLAYER")
            return nil
        }
        
        return player
    }
    
}
