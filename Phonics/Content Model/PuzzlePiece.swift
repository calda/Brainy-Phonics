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
    
    var row: Int
    var col: Int
    
    var imageName: String?
    var image: UIImage? {
        guard let imageName = self.imageName else { return nil }
        
        func jpng() -> UIImage? {
            guard let url = Bundle.phonicsBundle?.url(forResource: imageName, withExtension: "jpng") else { return nil }
            guard let data = try? Data(contentsOf: url) else { return nil }
            return UIImageWithJPNGData(data, 1.0, .up)
        }
        
        return jpng() ?? UIImage(named: imageName)
    }
    
    
    //MARK: - Relevant Geometry bits
    
    static let nubHeightRelativeToPieceWidth: CGFloat = 0.2
    
    
}
