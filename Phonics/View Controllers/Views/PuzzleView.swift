//
//  PuzzleView.swift
//  Phonics
//
//  Created by Cal Stephens on 8/16/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class PuzzleView : UIView {
    
    
    //MARK: - Properties
    
    var puzzle: Puzzle?
    
    //Whether or not the piece at the given (row, col) is visible. Defaults to true.
    var isPieceVisible: ((Int, Int) -> Bool)? {
        didSet {
            self.updatePieceVisibility()
        }
    }
    
    @IBInspectable var puzzleName: String? {
        didSet {
            self.puzzle = nil
            self.reload()
        }
    }
    
    @IBInspectable var spacing: CGFloat = 0 {
        didSet {
            self.reload()
        }
    }
    
    
    //MARK: - Layout Subviews
    
    override func prepareForInterfaceBuilder() {
        self.createImageViews()
    }
    
    func reload() {
        //remove all constraints that affect subviews
        var constraintsToRemove = [NSLayoutConstraint]()
        
        for constraint in self.constraints {
            if let view1 = constraint.firstItem as? UIView,
               let view2 = constraint.secondItem as? UIView {
                
                if view1.superview == self || view2.superview == self {
                    constraintsToRemove.append(constraint)
                }
            }
        }
        
        self.removeConstraints(constraintsToRemove)
        
        self.subviews.forEach{ $0.removeFromSuperview() }
        self.createImageViews()
        self.updatePieceVisibility()
    }
    
    func createImageViews() {
        if self.puzzle == nil {
            guard let puzzleName = self.puzzleName else { return }
            self.puzzle = Puzzle(fromSpecForPuzzleNamed: puzzleName)
        }
        
        guard let puzzle = self.puzzle else { return }
        
        let emptyColumn = [PuzzlePieceView!](repeating: nil, count: puzzle.colCount)
        var pieceViews = [[PuzzlePieceView!]](repeating: emptyColumn, count: puzzle.rowCount)
        
        //create subviews
        puzzle.pieces.forEach { row in
            row.forEach { piece in
                guard let pieceImage = piece.image else { return }
                
                let pieceView = PuzzlePieceView(piece: piece, pieceImage: pieceImage)
                pieceView.translatesAutoresizingMaskIntoConstraints = false
                pieceViews[piece.row][piece.col] = pieceView
                self.addSubview(pieceView)
            }
        }
        
        func pieceAt(_ row: Int, _ col: Int) -> PuzzlePieceView? {
            if row < 0 || row >= puzzle.rowCount { return nil }
            if col < 0 || col >= puzzle.colCount { return nil }
            return pieceViews[row][col]
        }
        
        //add constraints
        
        //all pieces are 1:1 aspect and equal in height to top corner
        guard let topCornerPiece = pieceAt(0, 0) else { return }
        
        let piecesWide = CGFloat(puzzle.colCount)
        let spacingWidth = (piecesWide - 1) * spacing
        self.widthAnchor.constraint(equalTo: topCornerPiece.widthAnchor, multiplier: piecesWide, constant: spacingWidth).isActive = true
        
        let piecesTall = CGFloat(puzzle.rowCount)
        let spacingHeight = (piecesTall - 1) * spacing
        self.heightAnchor.constraint(equalTo: topCornerPiece.heightAnchor, multiplier: piecesTall, constant: spacingHeight).isActive = true
        
        for row in 0 ..< puzzle.rowCount {
            for col in 0 ..< puzzle.colCount {
                guard let piece = pieceAt(row, col) else { continue }
                
                //width
                if let topCornerPiece = pieceAt(0, 0) {
                    let matchWidthConstraint = piece.widthAnchor.constraint(equalTo: topCornerPiece.widthAnchor)
                    matchWidthConstraint.priority = 900
                    matchWidthConstraint.isActive = true
                }
                
                //aspect ratio
                piece.widthAnchor.constraint(equalTo: piece.heightAnchor).isActive = true
                
                func constrain<T>(_ anchor: NSLayoutAnchor<T>, to pieceAnchor: NSLayoutAnchor<T>?, otherwise viewAnchor: NSLayoutAnchor<T>) {
                    if let pieceAnchor = pieceAnchor {
                        anchor.constraint(equalTo: pieceAnchor, constant: -self.spacing).isActive = true
                    } else {
                        anchor.constraint(equalTo: viewAnchor).isActive = true
                    }
                }
                
                //top
                let pieceAbove = pieceAt(row - 1, col)
                constrain(piece.topAnchor,
                          to: pieceAbove?.bottomAnchor,
                          otherwise: self.topAnchor)
                
                //bottom
                let pieceBelow = pieceAt(row + 1, col)
                constrain(piece.bottomAnchor,
                          to: pieceBelow?.topAnchor,
                          otherwise: self.bottomAnchor)
                
                //left
                let pieceToLeft = pieceAt(row, col - 1)
                constrain(piece.leftAnchor,
                          to: pieceToLeft?.rightAnchor,
                          otherwise: self.leftAnchor)
                
                //right
                let pieceToRight = pieceAt(row, col + 1)
                constrain(piece.rightAnchor,
                          to: pieceToRight?.leftAnchor,
                          otherwise: self.rightAnchor)
            }
        }
    }
    
    func updatePieceVisibility() {
        for subview in subviews {
            if let pieceView = subview as? PuzzlePieceView {
                let isVisible = self.isPieceVisible?(pieceView.piece.row, pieceView.piece.col) ?? true
                pieceView.isHidden = !isVisible
            }
        }
    }
    
}


//MARK: - Subview to manage individual pieces

class PuzzlePieceView : UIView {
    
    var piece: PuzzlePiece
    var imageView: UIImageView?
    
    init(piece: PuzzlePiece, pieceImage: UIImage) {
        
        self.piece = piece
        super.init(frame: .zero)
        self.clipsToBounds = false
        
        let imageView = UIImageView(image: pieceImage)
        self.imageView = imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        //create subviews to represent different possible nub configurations
        let nubRatio = PuzzlePiece.nubHeightRelativeToPieceWidth + 1.0
        
        let topNubAlign = UIView()
        topNubAlign.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(topNubAlign)
        topNubAlign.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: nubRatio).isActive = true
        topNubAlign.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        topNubAlign.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        topNubAlign.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        let leftNubAlign = UIView()
        leftNubAlign.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(leftNubAlign)
        leftNubAlign.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: nubRatio).isActive = true
        leftNubAlign.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        leftNubAlign.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        leftNubAlign.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        
        //set piece constraints
        
        //top
        if piece.topNubDirection == .outside {
            imageView.topAnchor.constraint(equalTo: topNubAlign.topAnchor).isActive = true
        } else {
            imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        }
        
        //left
        if piece.leftNubDirection == .outside {
            imageView.leftAnchor.constraint(equalTo: leftNubAlign.leftAnchor).isActive = true
        } else {
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        }
        
        //width and height
        var relativeWidth: CGFloat = 1.0
        var relativeHeight: CGFloat = 1.0
        let nubHeight = PuzzlePiece.nubHeightRelativeToPieceWidth
        
        if piece.topNubDirection    == .outside { relativeHeight += nubHeight }
        if piece.bottomNubDirection == .outside { relativeHeight += nubHeight }
        if piece.leftNubDirection   == .outside { relativeWidth += nubHeight }
        if piece.rightNubDirection  == .outside { relativeWidth += nubHeight }
        
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: relativeWidth).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: relativeHeight).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
