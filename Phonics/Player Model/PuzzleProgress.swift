//
//  PuzzleProgress.swift
//  Phonics
//
//  Created by Cal Stephens on 12/22/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation

class PuzzleProgress: NSCoding {
    
    let puzzleName: String
    var ownedPieces: [[Bool]]
    
    init(newFor puzzle: Puzzle) {
        self.puzzleName = puzzle.name
        
        let emptyColumn = [Bool](repeating: false, count: puzzle.colCount)
        self.ownedPieces = [[Bool]](repeating: emptyColumn, count: puzzle.rowCount)
        
        //set one piece to be initially visible
        self.addRandomPiece()
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
        encoder.setValue(self.puzzleName, forKey: Key.puzzleName)
        encoder.setValue(self.ownedPieces, forKey: Key.ownedPieces)
    }
    
}


//MARK: - Helpers

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




