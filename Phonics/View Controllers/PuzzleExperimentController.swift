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



//MARK: - Puzzle Piece, renders self using Nub Directions




