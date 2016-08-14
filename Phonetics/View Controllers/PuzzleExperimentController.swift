//
//  PuzzleExperimentController.swift
//  Phonetics
//
//  Created by Cal Stephens on 8/12/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class PuzzleExperimentController : UIViewController {
    
    override func viewDidLoad() {
        let piece = PuzzlePiece(topNub: .outside, rightNub: .outside, bottomNub: .inside, leftNub: .outside)
        let bezierPath = piece.path(origin: CGPoint(x: 100, y: 100), width: 75)
        
        let image = UIImage(named: "puzzle-test")!
        /*
        
        let mask = CAShapeLayer()
        mask.path = bezierPath.CGPath
        imageView.layer.mask = mask*/
        
        let pieceImage = piece.cropPiece(at: .zero, fromFlippedImage: image.flipped, width: 150)
        
        let imageView = UIImageView(image: pieceImage)
        imageView.frame = CGRect(x: 100, y: 100, width: 150, height: 150)
        self.view.addSubview(imageView)
    }
    
}



//MARK: - Puzzle, creates pieces with consistent nub directions

struct Puzzle {
    
    let pieces: [[PuzzlePiece]]
    
    init(rows: Int, cols: Int) {
        let emptyRow = [PuzzlePiece?](count: cols, repeatedValue: nil)
        var puzzle = [[PuzzlePiece?]](count: rows, repeatedValue: emptyRow)
        
        func pieceAt(row: Int, _ col: Int) -> PuzzlePiece? {
            if row < 0 || row >= rows { return nil }
            if col < 0 || col >= cols { return nil }
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
    
    func drawWithPieceSettings(infoForPiece: (row: Int, col: Int) -> (location: CGPoint, width: CGFloat)) {
        /*for (col, rowPieces) in pieces.enumerate() {
            for (row, piece) in rowPieces.enumerate() {
                let (location, width) = infoForPiece(row: row, col: col)
                piece.drawInCurrentContext(at: location, width: width)
            }
        }*/
    }
    
}


//MARK: - Puzzle Piece, renders self using Nub Directions

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
    
    let topNubDirection: Direction?
    let rightNubDirection: Direction?
    let bottomNubDirection: Direction?
    let leftNubDirection: Direction?
    
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
    
    
    
    //MARK: - Render Puzzle Piece
    
    func size(forWidth width: CGFloat) -> CGSize {
        var size = CGSize(width: width, height: width)
        let nubLength = width * 0.175
        
        if topNubDirection    != nil { size.height += nubLength }
        if bottomNubDirection != nil { size.height += nubLength }
        if leftNubDirection   != nil { size.width += nubLength }
        if rightNubDirection  != nil { size.width += nubLength }
        
        return size
    }
    
    func cropPiece(at imageOrigin: CGPoint, fromFlippedImage sourceImage: UIImage, width: CGFloat) -> UIImage {
        let contextSize = self.size(forWidth: width)
        UIGraphicsBeginImageContextWithOptions(contextSize, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        let nubLength = width * 0.175
        let originInContext = CGPoint(x: (self.leftNubDirection == nil ? 0 : nubLength),
                                      y: (self.topNubDirection == nil ? 0 : nubLength))
        
        let piecePath = path(origin: originInContext, width: width)
        CGContextAddPath(context, piecePath.CGPath)
        CGContextClip(context)
        
        let originOfImage = imageOrigin - originInContext.vectorFromOrigin()
        let rectOfImage = CGRect(origin: originOfImage, size: contextSize)
        CGContextDrawImage(context, rectOfImage, sourceImage.CGImage)
        
        let pieceImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return pieceImage
    }
    
    func path(origin origin: CGPoint, width: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(origin)
        
        var currentPoint = origin
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
        return path
    }
}


//MARK: - Render Puzzle Piece line with Nub

extension UIBezierPath {
    
    func addPuzzleLineFrom(from start: CGPoint, to end: CGPoint, facing direction: PuzzlePiece.Direction) {
        
        //define critical vectors
        
        let lineTranslation = start.direction(of: end)
        let lineDirection = lineTranslation.magnitude()
        let lineDistance = start.distance(to: end)
        
        let nubDirection = lineDirection.rotated(clockwise: direction.isClockwise)
        let nubHeight = lineDistance * 0.2
        let nubWidth = lineDistance * 0.175
        
        //draw points
        
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


extension UIImage {
    
    var flipped: UIImage {
        let cgImage = self.CGImage
        let size = CGSize(width: CGImageGetWidth(cgImage), height: CGImageGetHeight(cgImage))
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, CGRect(origin: .zero, size: size), cgImage)
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flippedImage
    }
    
}


//MARK: - Core Graphics extensions

extension CGPoint {
    
    func distance(to other: CGPoint) -> CGFloat {
        return sqrt( pow(other.x - self.x, 2) + pow(other.y - self.y, 2) );
    }
    
    func direction(of other: CGPoint) -> CGVector {
        return CGVector(dx: other.x - self.x, dy: other.y - self.y)
    }
    
    func vectorFromOrigin() -> CGVector {
        return CGPoint.zero.direction(of: self)
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

