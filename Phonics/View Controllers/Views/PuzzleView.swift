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
    
    @IBInspectable var puzzleName: String? {
        didSet {
            self.reload()
        }
    }
    
    private var puzzle: Puzzle?
    
    @IBInspectable var spacing: CGFloat = 0
    @IBInspectable var scaleToFitBasedOnSpacing: Bool = false
    
    @IBInspectable var clipsPieces: Bool {
        set { self.clipsToBounds = clipsPieces }
        get { return self.clipsToBounds }
    }
    
    @IBInspectable var allowInteractionWithPieces: Bool {
        set { self.isUserInteractionEnabled = allowInteractionWithPieces }
        get { return self.isUserInteractionEnabled }
    }
    
    
    //MARK: - Computed Properties
    
    var sizeOfPuzzle: CGSize {
        guard let puzzle = puzzle else { return .zero }
        var imageSize = puzzle.pixelSize
        
        if scaleToFitBasedOnSpacing && spacing > 0 && puzzle.rowCount > 0 && puzzle.colCount > 0 {
            imageSize.height += CGFloat(puzzle.rowCount - 1) * spacing
            imageSize.width += CGFloat(puzzle.colCount - 1) * spacing
        }
        
        var width = self.frame.size.width
        var height = width * (imageSize.height / imageSize.width)
        
        if height > frame.size.height {
            height = self.frame.size.height
            width = height * (imageSize.width / imageSize.height)
        }
        
        return CGSize(width: width, height: height)
    }
    
    var originOfPuzzle: CGPoint {
        let sizeDifference = CGSize(width: abs(sizeOfPuzzle.width - self.frame.width),
                                    height: abs(sizeOfPuzzle.height - self.frame.height))
        return CGPoint(x: sizeDifference.width / 2,
                       y: sizeDifference.height / 2)
    }
    
    var sizeOfPiece: CGSize {
        guard let puzzle = self.puzzle else { return .zero }
        let widthFromSpacing = self.spacing * CGFloat(puzzle.colCount - 1)
        let width = (sizeOfPuzzle.width - widthFromSpacing) / CGFloat(puzzle.colCount)
        
        let heightFromSpacing = self.spacing * CGFloat(puzzle.rowCount - 1)
        let height = (sizeOfPuzzle.height - heightFromSpacing) / CGFloat(puzzle.rowCount)
        
        return CGSize(width: width, height: height)
    }
    
    func originForPieceAt(row: Int, col: Int) -> CGPoint {
        let size = self.sizeOfPiece
        let offset = CGVector(dx: (size.width + spacing) * CGFloat(col),
                              dy: (size.height + spacing) * CGFloat(row))
        
        return CGPoint(x: self.originOfPuzzle.x + offset.dx,
                       y: self.originOfPuzzle.y + offset.dy)
    }
    
    func frameForPieceAt(row: Int, col: Int) -> CGRect {
        let originOfPiece = self.originForPieceAt(row: row, col: col)
        return CGRect(origin: originOfPiece, size: self.sizeOfPiece)
    }
    
    
    //MARK: - Layout Subviews
    
    override func awakeFromNib() {
        self.createImageViews()
    }
    
    override func prepareForInterfaceBuilder() {
        self.createImageViews()
    }
    
    func reload() {
        self.subviews.forEach{ $0.removeFromSuperview() }
        self.createImageViews()
    }
    
    func createImageViews() {
        guard let puzzleName = self.puzzleName else { return }
        self.puzzle = Puzzle(fromSpecForPuzzleNamed: puzzleName)
        
        guard let puzzle = self.puzzle else { return }
        puzzle.pieces.forEach { row in
            row.forEach { piece in
                guard let pieceRow = piece.row, let pieceCol = piece.col else { return }
                guard let pieceImage = piece.image else { return }

                let frame = self.frameForPieceAt(row: pieceRow, col: pieceCol)
                let pieceView = PuzzlePieceView(frame: frame, piece: piece, pieceImage: pieceImage)
                
                self.addSubview(pieceView)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutPieces(animate: true)
    }
    
    func layoutPieces(animate: Bool = false) {
        for subview in self.subviews {
            guard let pieceView = subview as? PuzzlePieceView else { continue }
            guard let row = pieceView.piece.row, let col = pieceView.piece.col else { continue }
            let newFrame = self.frameForPieceAt(row: row, col: col)
            pieceView.updateImageView(for: newFrame, animate: animate)
        }
    }
    
}


//MARK: - Subview to manage individual pieces

class PuzzlePieceView : UIView {
    
    var piece: PuzzlePiece
    var imageView: UIImageView?
    
    init(frame: CGRect, piece: PuzzlePiece, pieceImage: UIImage) {
        self.piece = piece
        super.init(frame: frame)
        self.clipsToBounds = false
        
        self.imageView = UIImageView(frame: .zero)
        self.imageView!.image = pieceImage
        self.updateImageView(for: frame, animate: false)
        
        self.addSubview(imageView!)
    }
    
    func updateImageView(for frame: CGRect, animate: Bool) {
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [.curveEaseIn], animations: {
                self.frame = frame
            }, completion: nil)
        
        let width = frame.size.width
        let imageSize = self.piece.size(forWidth: width)
        let imageOffset = self.piece.imageOrigin(relativeTo: .zero, forWidth: width)
        
        let imageFrame = CGRect(origin: imageOffset, size: imageSize)
        
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [.curveEaseIn], animations: {
                self.imageView?.frame = imageFrame
            }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
