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
        
        
        let puzzle = Puzzle(rows: 5, cols: 8)
        let sourceImage = UIImage(named: "puzzle-test")!
        
        puzzle.createImages(from: sourceImage).map { (image, piece, row, col) in
            
            let imageView = UIImageView(image: image)
            let size = piece.size(forWidth: 50)
            
            let origin = CGPoint(x: 65 * col + 50, y: 65 * row + 50)
            let imageOrigin = piece.imageOrigin(relativeTo: origin, forWidth: 50)
            imageView.frame = CGRect(origin: imageOrigin, size: size)
            
            return imageView
            
        }.forEach(self.view.addSubview)
        
        
    }
    
}



//MARK: - Puzzle, creates pieces with consistent nub directions

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
    
    func createImages(from image: UIImage) -> [(image: UIImage, piece: PuzzlePiece, row: Int, col: Int)] {
        var images = [(image: UIImage, piece: PuzzlePiece, row: Int, col: Int)]()
        let flippedImage = image.flipped
        
        let cgImage = image.CGImage
        let imageWidth = CGFloat(CGImageGetWidth(cgImage))
        let imageHeight = CGFloat(CGImageGetHeight(cgImage))
        
        let pieceWidth = imageWidth / CGFloat(self.colCount)
        let pieceHeight = imageHeight / CGFloat(self.rowCount)
        
        for (row, rowPieces) in pieces.enumerate() {
            for (col, piece) in rowPieces.enumerate() {
                let originInImage = CGPoint(x: Int(pieceWidth) * col, y: Int(pieceHeight) * row)
                let pieceImage = piece.cropPiece(at: originInImage, fromFlippedImage: flippedImage, width: pieceWidth, multiplyByDeviceScale: false)
                images.append(image: pieceImage, piece: piece, row: row, col: col)
            }
        }
        
        return images
    }
    
}


//MARK: - Puzzle Piece, renders self using Nub Directions

struct PuzzlePiece {
    
    
    //MARK: - Direction of Nub
    
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
    
    static let nubHeightRelativeToPieceWidth: CGFloat = 0.2
    static let nubWidthRelativeToPieceWidth: CGFloat = 0.175
    static let distanceBeforeNubRelativeToPieceWidth: CGFloat = (1.0 - nubWidthRelativeToPieceWidth) / 2.0
    
    func size(forWidth width: CGFloat) -> CGSize {
        var size = CGSize(width: width, height: width)
        let nubLength = width * PuzzlePiece.nubHeightRelativeToPieceWidth
        
        if topNubDirection    == .outside { size.height += nubLength }
        if bottomNubDirection == .outside { size.height += nubLength }
        if leftNubDirection   == .outside { size.width += nubLength }
        if rightNubDirection  == .outside { size.width += nubLength }
        
        return size
    }
    
    func imageOrigin(relativeTo pieceOrigin: CGPoint, forWidth width: CGFloat) -> CGPoint {
        var imageOrigin = pieceOrigin
        
        let nubLength = width * PuzzlePiece.nubHeightRelativeToPieceWidth
        if self.leftNubDirection == .outside { imageOrigin.x -= nubLength }
        if self.topNubDirection  == .outside { imageOrigin.y -= nubLength }
        
        return imageOrigin
    }
    
    func cropPiece(at imageOriginUnscaled: CGPoint, fromFlippedImage sourceImage: UIImage, width widthUnscaled: CGFloat, multiplyByDeviceScale: Bool = true) -> UIImage {
        
        let deviceScale = UIScreen.mainScreen().scale
        let imageOrigin = (multiplyByDeviceScale ? imageOriginUnscaled * deviceScale : imageOriginUnscaled)
        let width = (multiplyByDeviceScale ? widthUnscaled * deviceScale : widthUnscaled)
        
        let contextSize = self.size(forWidth: width)
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        let nubLength = width * PuzzlePiece.nubHeightRelativeToPieceWidth
        let originOfBezierPath = CGPoint(x: (self.leftNubDirection == .outside ? nubLength : 0),
                                         y: (self.topNubDirection == .outside ? nubLength : 0))
        
        let piecePath = path(origin: originOfBezierPath, width: width)
        CGContextAddPath(context, piecePath.CGPath)
        CGContextClip(context)
        
        let originInImage = imageOrigin - originOfBezierPath.vectorFromOrigin()
        
        let cgImage = sourceImage.CGImage
        let imageSize = CGSize(width: CGImageGetWidth(cgImage), height: CGImageGetHeight(cgImage))
        let imageRectInContext = CGRect(origin: .zero, size: imageSize)
        
        CGContextTranslateCTM(context, -originInImage.x, -originInImage.y)
        CGContextDrawImage(context, imageRectInContext, sourceImage.CGImage)
        CGContextTranslateCTM(context, originInImage.x, originInImage.y)
        
        UIColor(white: 0.0, alpha: 0.5).setStroke()
        piecePath.lineWidth = 5.0
        piecePath.stroke()
        
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
                self.addPuzzleLineFrom(from: currentPoint, to: nextPoint, facing: direction, on: path)
            } else {
                path.addLineToPoint(nextPoint)
            }
            
            vector = vector.rotated(clockwise: false, degrees: 90)
            currentPoint = nextPoint
        }
        
        path.closePath()
        return path
    }
    
    func addPuzzleLineFrom(from start: CGPoint, to end: CGPoint, facing direction: PuzzlePiece.Direction, on path: UIBezierPath) {

        //define critical vectors
        
        let lineTranslation = start.direction(of: end)
        let lineDirection = lineTranslation.magnitude()
        let lineDistance = start.distance(to: end)
        
        let nubDirection = lineDirection.rotated(clockwise: direction.isClockwise)
        let nubHeight = lineDistance * PuzzlePiece.nubHeightRelativeToPieceWidth
        let nubWidth = lineDistance * PuzzlePiece.nubWidthRelativeToPieceWidth
        
        //draw points
        
        let nubBaseLeft = start + (lineTranslation * PuzzlePiece.distanceBeforeNubRelativeToPieceWidth)
        path.addLineToPoint(nubBaseLeft)
        
        let nubTopLeft = nubBaseLeft + (nubDirection * nubHeight)
        let nubTopLeft_cp1 = nubBaseLeft + (nubDirection * nubHeight * 0.4).rotated(clockwise: direction.isClockwise, degrees: 15)
        let nubTopLeft_cp2 = nubTopLeft + (-lineTranslation * 0.15)
        path.addCurveToPoint(nubTopLeft, controlPoint1: nubTopLeft_cp1, controlPoint2: nubTopLeft_cp2)
        
        let nubTopRight = nubTopLeft + (lineDirection * nubWidth)
        path.addLineToPoint(nubTopRight)
        
        let nubBaseRight = nubTopRight - (nubDirection * nubHeight)
        let nubBaseRight_cp1 = nubTopRight + (lineTranslation * 0.15)
        let nubBaseRight_cp2 = nubBaseRight + (nubDirection * nubHeight * 0.4).rotated(clockwise: direction.isClockwise, degrees: -15)
        path.addCurveToPoint(nubBaseRight, controlPoint1: nubBaseRight_cp1, controlPoint2: nubBaseRight_cp2)
        
        path.addLineToPoint(end)
    }
}


//MARK: - Graphics Extensions

extension UIImage {
    
    var flipped: UIImage {
        let cgImage = self.CGImage
        let size = CGSize(width: CGImageGetWidth(cgImage), height: CGImageGetHeight(cgImage))
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, CGRect(origin: .zero, size: size), cgImage)
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flippedImage
    }
    
}

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


//MARK: - CGVector Operators

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


//MARK: - CGPoint Operations

prefix func -(point: CGPoint) -> CGPoint {
    return CGPoint(x: -point.x, y: -point.y)
}

func +(point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x + vector.dx, y: point.y + vector.dy)
}

func -(point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x - vector.dx, y: point.y - vector.dy)
}

func *(point1: CGPoint, point2: CGPoint) -> CGPoint {
    return CGPoint(x: point1.x * point2.x, y: point1.y * point2.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
