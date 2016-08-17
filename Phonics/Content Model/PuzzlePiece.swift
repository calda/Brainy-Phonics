//
//  PuzzlePiece.swift
//  Phonics
//
//  Created by Cal Stephens on 8/16/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation

struct PuzzlePiece {
    
    enum Direction {
        case outside, inside
        
        var isClockwise: Bool {
            switch(self) {
            case .outside: return true
            case .inside: return false
            }
        }
        
        var opposite: Direction {
            switch(self) {
            case .outside: return .inside
            case .inside: return .outside
            }
        }
        
        static var random: Direction {
            return (arc4random() % 2 == 0 ? .outside : .inside)
        }
    }
    
    
    //MARK: - Initializers
    
    let topNubDirection: Direction?
    let rightNubDirection: Direction?
    let bottomNubDirection: Direction?
    let leftNubDirection: Direction?
    
    var row: Int?
    var col: Int?
    
    init(topNub: Direction?, rightNub: Direction?, bottomNub: Direction?, leftNub: Direction?) {
        topNubDirection = topNub
        rightNubDirection = rightNub
        bottomNubDirection = bottomNub
        leftNubDirection = leftNub
    }
    
    init(topNeighbor: PuzzlePiece?, rightNeighbor: PuzzlePiece?, bottomNeighbor: PuzzlePiece?, leftNeighbor: PuzzlePiece?) {
        topNubDirection = topNeighbor?.bottomNubDirection?.opposite
        rightNubDirection = rightNeighbor?.leftNubDirection?.opposite
        bottomNubDirection = bottomNeighbor?.topNubDirection?.opposite
        
        leftNubDirection = leftNeighbor?.rightNubDirection?.opposite
    }
    
    static var withRandomNubs: PuzzlePiece {
        return PuzzlePiece(topNub: .random, rightNub: .random, bottomNub: .random, leftNub: .random)
    }
    
}