//
//  Puzzle.swift
//  Phonics
//
//  Created by Cal Stephens on 8/16/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation

struct Puzzle {
    
    let pieces: [[PuzzlePiece]]
    let rowCount: Int
    let colCount: Int
    
    init(rows: Int, cols: Int) {
        
        self.rowCount = rows
        self.colCount = cols
        
        let emptyRow = [PuzzlePiece?](count: cols, repeatedValue: nil)
        var puzzle = [[PuzzlePiece?]](count: rows, repeatedValue: emptyRow)
        
        func pieceAt(row: Int, _ col: Int) -> PuzzlePiece? {
            if !(0 ..< rows).contains(row) { return nil }
            if !(0 ..< cols).contains(col) { return nil }
            return puzzle[row][col] ?? PuzzlePiece.withRandomNubs
        }
        
        for row in 0 ..< rows {
            for col in 0 ..< cols {
                puzzle[row][col] = PuzzlePiece(topNeighbor: pieceAt(row - 1, col),
                                               rightNeighbor: pieceAt(row, col + 1),
                                               bottomNeighbor: pieceAt(row + 1, col),
                                               leftNeighbor: pieceAt(row, col - 1))
            }
        }
        
        //reduce [[PuzzlePiece?]] to [[PuzzlePiece]]
        self.pieces = puzzle.map { pieceRow in
            return pieceRow.flatMap{ $0 }
        }
    }
    
}

