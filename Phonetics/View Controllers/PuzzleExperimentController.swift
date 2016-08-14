//
//  PuzzleExperimentController.swift
//  Phonetics
//
//  Created by Cal Stephens on 8/12/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class PuzzleExperimentController : UIViewController {
    
}

class PuzzleView: UIView {
    
    override func drawRect(rect: CGRect) {
        self.backgroundColor = UIColor.grayColor()
        
        UIColor.redColor().setFill()
        UIColor.blueColor().setStroke()
        
        
        var puzzleDirections: [[PuzzlePiece.Direction]] = []
        
        for _ in (1 ... 19) {
            var row: [PuzzlePiece.Direction] = []
            for _ in (1 ... 19) {
                row.append(PuzzlePiece.Direction.random)
            }
            puzzleDirections.append(row)
        }
        
        func directionFor(row: Int, _ col: Int) -> PuzzlePiece.Direction? {
            if row < 0 || row >= 19 { return nil }
            if col < 0 || col >= 19 { return nil }
            return puzzleDirections[row][col]
        }
        
        
        var puzzle: [[PuzzlePiece]] = []
        
        for row in (1 ... 20) {
            var puzzleRow: [PuzzlePiece] = []
            for col in (1 ... 20) {
            
                let piece = PuzzlePiece(topNubDirection: directionFor(row - 1, col),
                                        rightNubDirection: directionFor(row, col + 1),
                                        bottomNubDirection: directionFor(row + 1, col),
                                        leftNubDirection: directionFor(row, col - 1))
                
                puzzleRow.append(piece)
                
            }
            puzzle.append(puzzleRow)
        }
        
        
        for (row, pieces) in puzzle.enumerate() {
            for (col, piece) in pieces.enumerate() {
                piece.drawInCurrentContext(at: CGPoint(x: row * 50, y: col * 50), width: 50)
            }
        }
        
        
        
        UIColor.blueColor().setStroke()
        //puzzlePiece.drawInCurrentContext(at: CGPoint(x: 100, y: 100), width: 200)
        
    }

}

struct PuzzlePiece {
    
    enum Direction {
        case outside, inside
        
        var isClockwise: Bool {
            switch(self) {
            case .outside: return true
            case .inside: return false
            }
        }
        
        static var random: Direction {
            return (arc4random() % 2 == 0 ? .outside : .inside)
        }
    }
    
    let topNubDirection: Direction?
    let rightNubDirection: Direction?
    let bottomNubDirection: Direction?
    let leftNubDirection: Direction?
    
    func drawInCurrentContext(at start: CGPoint, width: CGFloat) {
        let path = UIBezierPath()
        path.moveToPoint(start)
        
        var currentPoint = start
        var vector = CGVector(dx: width, dy: 0)
        
        for direction in [topNubDirection, rightNubDirection, bottomNubDirection, leftNubDirection] {
            let nextPoint = currentPoint + vector
            
            if let direction = direction {
                path.addPuzzleLineFrom(from: currentPoint, to: nextPoint, facing: direction)
            } else {
                path.addLineToPoint(nextPoint)
            }
            
            vector = vector.rotated(clockwise: false, degrees: 90)
            currentPoint = nextPoint
        }
        
        path.closePath()
        path.stroke()
    }
}

extension UIBezierPath {
    
    func addPuzzleLineFrom(from start: CGPoint, to end: CGPoint, facing direction: PuzzlePiece.Direction) {
        
        //define critical vectors
        
        let lineTranslation = start.direction(of: end)
        let lineDirection = lineTranslation.magnitude()
        let lineDistance = start.distance(to: end)
        
        let nubDirection = lineDirection.rotated(clockwise: direction.isClockwise)
        let nubHeight = lineDistance * 0.2
        let nubWidth = lineDistance * 0.175
        
        //define points
        
        let nubBaseLeft = start + (lineTranslation * 0.4125)
        self.addLineToPoint(nubBaseLeft)
        
        let nubTopLeft = nubBaseLeft + (nubDirection * nubHeight)
        let nubTopLeft_cp1 = nubBaseLeft + (nubDirection * nubHeight * 0.4).rotated(clockwise: direction.isClockwise, degrees: 15)
        let nubTopLeft_cp2 = nubTopLeft + (-lineTranslation * 0.15)
        self.addCurveToPoint(nubTopLeft, controlPoint1: nubTopLeft_cp1, controlPoint2: nubTopLeft_cp2)
        
        let nubTopRight = nubTopLeft + (lineDirection * nubWidth)
        self.addLineToPoint(nubTopRight)
        
        let nubBaseRight = nubTopRight - (nubDirection * nubHeight)
        let nubBaseRight_cp1 = nubTopRight + (lineTranslation * 0.15)
        let nubBaseRight_cp2 = nubBaseRight + (nubDirection * nubHeight * 0.4).rotated(clockwise: direction.isClockwise, degrees: -15)
        self.addCurveToPoint(nubBaseRight, controlPoint1: nubBaseRight_cp1, controlPoint2: nubBaseRight_cp2)
        
        self.addLineToPoint(end)
    }
    
}

extension CGPoint {
    
    func distance(to other: CGPoint) -> CGFloat {
        return sqrt( pow(other.x - self.x, 2) + pow(other.y - self.y, 2) );
    }
    
    func direction(of other: CGPoint) -> CGVector {
        return CGVector(dx: other.x - self.x, dy: other.y - self.y)
    }
    
}

extension CGVector {
    
    func rotated(clockwise useClockwise: Bool, degrees: CGFloat = 90.0) -> CGVector {
        let multiplier: CGFloat = (useClockwise ? -1 : 1)
        let radians = (degrees * multiplier * CGFloat(M_PI)) / 180
        let transform = CGAffineTransformMakeRotation(radians)
        
        let selfAsPoint = CGPoint(x: self.dx, y: self.dy)
        let rotatedPoint = CGPointApplyAffineTransform(selfAsPoint, transform)
        return CGVector(dx: rotatedPoint.x, dy: rotatedPoint.y)
    }
    
    func magnitude() -> CGVector {
        let normalizedSelf = self.normalized()
        var vector = CGVector(dx: normalizedSelf.dx / abs(normalizedSelf.dx),
                              dy: normalizedSelf.dy / abs(normalizedSelf.dy))
        
        if vector.dx.isNaN { vector.dx = 0.0 }
        if vector.dy.isNaN { vector.dy = 0.0 }
        
        return vector
    }
    
    func normalized() -> CGVector {
        var normalizedSelf = self
        if abs(normalizedSelf.dx.distanceTo(0)) < 0.0001 { normalizedSelf.dx = 0.0 }
        if abs(normalizedSelf.dy.distanceTo(0)) < 0.0001 { normalizedSelf.dy = 0.0 }
        return normalizedSelf
    }
    
}

prefix func -(vector: CGVector) -> CGVector {
    return CGVector(dx: -vector.dx, dy: -vector.dy)
}

func *(vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

func *(vector1: CGVector, vector2: CGVector) -> CGVector {
    return CGVector(dx: vector1.dx * vector2.dx, dy: vector1.dy * vector2.dy)
}

func +(vector1: CGVector, vector2: CGVector) -> CGVector {
    return CGVector(dx: vector1.dx + vector2.dx, dy: vector1.dy + vector2.dy)
}

func +(point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x + vector.dx, y: point.y + vector.dy)
}

func -(point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x - vector.dx, y: point.y - vector.dy)
}




