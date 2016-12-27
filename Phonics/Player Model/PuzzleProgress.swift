//
//  PuzzleProgress.swift
//  Phonics
//
//  Created by Cal Stephens on 12/22/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation

class PuzzleProgress: NSObject, NSCoding {
    
    let puzzleName: String
    var ownedPieces: [[Bool]]
    
    var isComplete: Bool {
        var isComplete = true
        
        for column in ownedPieces {
            for piece in column {
                isComplete = piece && isComplete
            }
        }
        
        return isComplete
    }
    
    init(newFor puzzle: Puzzle) {
        self.puzzleName = puzzle.name
        
        let emptyColumn = [Bool](repeating: false, count: puzzle.colCount)
        self.ownedPieces = [[Bool]](repeating: emptyColumn, count: puzzle.rowCount)
        
        super.init()
    }
    
    @discardableResult func addRandomPiece() -> (row: Int, col: Int)? {
        var unownedPieces = [(row: Int, col: Int)]()
        
        for (row, wholeColumn) in ownedPieces.enumerated() {
            for (col, isOwnedByPlayer) in wholeColumn.enumerated() {
                if !isOwnedByPlayer {
                    unownedPieces.append((row, col))
                }
            }
        }
        
        let piece = unownedPieces.random()
        if let piece = piece {
            self.ownedPieces[piece.row][piece.col] = true
        }
        
        return piece
    }
    
    
    //MARK: - NSCoding
    
    private enum Key: String, NSCodingKey {
        case puzzleName = "PuzzleProgress.puzzleName"
        case ownedPieces = "PuzzleProgress.ownedPieces"
    }
    
    required init?(coder decoder: NSCoder) {
        guard let puzzleName = decoder.value(forKey: Key.puzzleName) as? String else { return nil }
        self.puzzleName = puzzleName
        
        guard let ownedPieces = decoder.value(forKey: Key.ownedPieces) as? [[Bool]] else { return nil }
        self.ownedPieces = ownedPieces
    }
    
    func encode(with encoder: NSCoder) {
        encoder.setValue(self.puzzleName, for: Key.puzzleName)
        encoder.setValue(self.ownedPieces, for: Key.ownedPieces)
    }
    
}


//MARK: - Accessor

extension Player {
    
    func progress(for puzzle: Puzzle) -> PuzzleProgress {
        if let progress = self.puzzleProgress[puzzle.name] {
            return progress
        } else {
            let newProgress = PuzzleProgress(newFor: puzzle)
            self.puzzleProgress[puzzle.name] = newProgress
            return newProgress
        }
    }
    
}
