//
//  PuzzleView.swift
//  Phonics
//
//  Created by Cal Stephens on 8/16/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit


//MARK: - Render Puzzle

extension Puzzle {
    
    func createImages(from image: UIImage, multiplyByDeviceScale: Bool) -> [(image: UIImage, piece: PuzzlePiece, row: Int, col: Int)] {
        var images = [(image: UIImage, piece: PuzzlePiece, row: Int, col: Int)]()
        let flippedImage = image.flipped
        
        let cgImage = image.cgImage
        let imageWidth = CGFloat((cgImage?.width)!)
        let imageHeight = CGFloat((cgImage?.height)!)
        
        let pieceWidth = imageWidth / CGFloat(self.colCount)
        let pieceHeight = imageHeight / CGFloat(self.rowCount)
        
        for (row, rowPieces) in pieces.enumerated() {
            for (col, piece) in rowPieces.enumerated() {
                let originInImage = CGPoint(x: Int(pieceWidth) * col, y: Int(pieceHeight) * row)
                let pieceImage = piece.cropPiece(at: originInImage, fromFlippedImage: flippedImage, width: pieceWidth, multiplyByDeviceScale: multiplyByDeviceScale)
                images.append(image: pieceImage, piece: piece, row: row, col: col)
            }
        }
        
        return images
    }
    
}


//MARK: - Render Puzzle Piece

extension PuzzlePiece {
    
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
        
        let deviceScale = UIScreen.main.scale
        let imageOrigin = (multiplyByDeviceScale ? imageOriginUnscaled * deviceScale : imageOriginUnscaled)
        let width = (multiplyByDeviceScale ? widthUnscaled * deviceScale : widthUnscaled)
        
        let contextSize = self.size(forWidth: width)
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        let nubLength = width * PuzzlePiece.nubHeightRelativeToPieceWidth
        let originOfBezierPath = CGPoint(x: (self.leftNubDirection == .outside ? nubLength : 0),
                                         y: (self.topNubDirection == .outside ? nubLength : 0))
        
        let piecePath = path(origin: originOfBezierPath, width: width)
        context?.addPath(piecePath.cgPath)
        context?.clip()
        
        let originInImage = imageOrigin - originOfBezierPath.vectorFromOrigin()
        
        let cgImage = sourceImage.cgImage
        let imageSize = CGSize(width: (cgImage?.width)!, height: (cgImage?.height)!)
        let imageRectInContext = CGRect(origin: .zero, size: imageSize)
        
        context?.translateBy(x: -originInImage.x, y: -originInImage.y)
        context?.draw(sourceImage.cgImage!, in: imageRectInContext)
        context?.translateBy(x: originInImage.x, y: originInImage.y)
        
        UIColor(white: 0.0, alpha: 0.5).setStroke()
        piecePath.lineWidth = 5.0
        piecePath.stroke()
        
        let pieceImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return pieceImage!
    }
    
    func path(origin: CGPoint, width: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: origin)
        
        var currentPoint = origin
        var vector = CGVector(dx: width, dy: 0)
        
        for direction in [topNubDirection, rightNubDirection, bottomNubDirection, leftNubDirection] {
            let nextPoint = currentPoint + vector
            
            if let direction = direction {
                self.addPuzzleLineFrom(from: currentPoint, to: nextPoint, facing: direction, on: path)
            } else {
                path.addLine(to: nextPoint)
            }
            
            vector = vector.rotated(clockwise: false, degrees: 90)
            currentPoint = nextPoint
        }
        
        path.close()
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
        path.addLine(to: nubBaseLeft)
        
        let nubTopLeft = nubBaseLeft + (nubDirection * nubHeight)
        let nubTopLeft_cp1 = nubBaseLeft + (nubDirection * nubHeight * 0.4).rotated(clockwise: direction.isClockwise, degrees: 15)
        let nubTopLeft_cp2 = nubTopLeft + (-lineTranslation * 0.15)
        path.addCurve(to: nubTopLeft, controlPoint1: nubTopLeft_cp1, controlPoint2: nubTopLeft_cp2)
        
        let nubTopRight = nubTopLeft + (lineDirection * nubWidth)
        path.addLine(to: nubTopRight)
        
        let nubBaseRight = nubTopRight - (nubDirection * nubHeight)
        let nubBaseRight_cp1 = nubTopRight + (lineTranslation * 0.15)
        let nubBaseRight_cp2 = nubBaseRight + (nubDirection * nubHeight * 0.4).rotated(clockwise: direction.isClockwise, degrees: -15)
        path.addCurve(to: nubBaseRight, controlPoint1: nubBaseRight_cp1, controlPoint2: nubBaseRight_cp2)
        
        path.addLine(to: end)
    }
    
}


//MARK: - Helper Extensions

extension UIImage {
    
    var flipped: UIImage {
        let cgImage = self.cgImage
        let size = CGSize(width: (cgImage?.width)!, height: (cgImage?.height)!)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        context?.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flippedImage!
    }
    
    //TODO: how can i do this? should i do it manually?
    /*var croppedToIntegerAspectRatio: (cropped: UIImage, unitsTall: Int, unitsWide: Int) {
        let currentRatio = self.size.height / self.size.width
    }*/
    
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
        let transform = CGAffineTransform(rotationAngle: radians)
        
        let selfAsPoint = CGPoint(x: self.dx, y: self.dy)
        let rotatedPoint = selfAsPoint.applying(transform)
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
        if abs(normalizedSelf.dx.distance(to: 0)) < 0.0001 { normalizedSelf.dx = 0.0 }
        if abs(normalizedSelf.dy.distance(to: 0)) < 0.0001 { normalizedSelf.dy = 0.0 }
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
