//
//  PuzzlePiece.swift
//  Phonics
//
//  Created by Cal Stephens on 8/16/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit

struct PuzzlePiece {
    
    enum Direction {
        case outside, inside
        
        static func fromString(_ string: String?) -> Direction? {
            if string == "outside" { return .outside }
            if string == "inside" { return .inside }
            return nil
        }
    }
    
    
    //MARK: - Initializers
    
    let topNubDirection: Direction?
    let rightNubDirection: Direction?
    let bottomNubDirection: Direction?
    let leftNubDirection: Direction?
    
    var row: Int?
    var col: Int?
    
    var imageName: String?
    var image: UIImage? {
        guard let imageName = self.imageName else { return nil }
        guard let url = Bundle.phonicsBundle?.url(forResource: imageName, withExtension: "jpng") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImageWithJPNGData(data, 1.0, .up)
    }
    
    
    //MARK: - Relevant Geometry bits
    
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
    
    
}
