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
        
        let start = CGPoint(x: 100, y: 100)
        let vector = CGVector(dx: 250, dy: 0)
        
        let path = UIBezierPath()
        path.lineJoinStyle = .Round
        path.lineWidth = 5.0
        
        path.moveToPoint(start)
        path.drawPuzzleLineFrom(from: start, to: start + vector, facing: .left)
        path.drawPuzzleLineFrom(from: start + vector, to: start + vector * 2, facing: .right)
    
        path.stroke()
        //path.fill()
    }

}

extension UIBezierPath {
    
    enum Direction {
        case left, right
        
        var isClockwise: Bool {
            switch(self) {
                case .left: return true
                case .right: return false
            }
        }
    }
    
    func drawPuzzleLineFrom(from start: CGPoint, to end: CGPoint, facing direction: Direction) {
        
        
        //define critical vectors
        
        let lineTranslation = start.direction(of: end)
        let lineDirection = lineTranslation.magnitude()
        let lineDistance = start.distance(to: end)
        
        let nubDirection = lineDirection.rotated(clockwise: direction.isClockwise)
        let nubHeight = lineDistance * 0.2
        let nubWidth = lineDistance * 0.2
        
        //define critical points
        
        let nubBaseLeft = start + (lineTranslation * 0.4)
        let nubTopLeft = nubBaseLeft + (nubDirection * nubHeight)
        let nubTopRight = nubTopLeft + (lineDirection * nubWidth)
        let nubBaseRight = nubTopRight - (nubDirection * nubHeight)
        
        
        //create points
        
        self.addLineToPoint(nubBaseLeft)
        
        var nubDirectionNormalized = nubDirection
        if nubDirectionNormalized.dx.distanceTo(0) < 0.0001 { nubDirectionNormalized.dx = 1.0 }
        if nubDirectionNormalized.dy.distanceTo(0) < 0.0001 { nubDirectionNormalized.dy = 1.0 }
        
        let leftControlPoint1 = nubBaseLeft + CGVector(dx: -lineDistance * 0.05, dy: nubHeight * 0.5) * nubDirectionNormalized
        let leftControlPoint2 = nubBaseLeft + CGVector(dx: 0, dy: nubHeight * 0.5) * nubDirectionNormalized
        self.addCurveToPoint(nubTopLeft, controlPoint1: leftControlPoint1, controlPoint2: leftControlPoint2)
        
        self.addLineToPoint(nubTopRight)
        
        let rightControlPoint1 = nubBaseRight + CGVector(dx: 0, dy: nubHeight * 0.5) * nubDirectionNormalized
        let rightControlPoint2 = nubBaseRight + CGVector(dx: lineDistance * 0.05, dy: nubHeight * 0.5) * nubDirectionNormalized
        self.addCurveToPoint(nubBaseRight, controlPoint1: rightControlPoint1, controlPoint2: rightControlPoint2)
    
        
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
        var vector = CGVector(dx: self.dx / abs(self.dx), dy: self.dy / abs(self.dy))
        
        if vector.dx.isNaN { vector.dx = 0.0 }
        if vector.dy.isNaN { vector.dy = 0.0 }
        
        return vector
    }
    
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




