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
    
    @IBInspectable var image: UIImage?
    @IBInspectable var rows: Int = 0
    @IBInspectable var cols: Int = 0
    
    @IBInspectable var spacing: CGFloat = 0
    @IBInspectable var scaleToFitBasedOnSpacing: Bool = false
    
    @IBInspectable var clipsPieces: Bool {
        set { self.clipsToBounds = clipsPieces }
        get { return self.clipsToBounds }
    }
    
    @IBInspectable var allowInteractionWithPieces: Bool {
        set { self.userInteractionEnabled = allowInteractionWithPieces }
        get { return self.userInteractionEnabled }
    }
    
    var dynamics: UIDynamicAnimator!
    
    
    //MARK: - Computed Properties
    
    var sizeOfPuzzle: CGSize {
        guard let image = self.image else { return .zero }
        
        var imageSize = image.size
        if scaleToFitBasedOnSpacing && spacing > 0 && rows > 0 && cols > 0 {
            imageSize.height += CGFloat(rows - 1) * spacing
            imageSize.width += CGFloat(cols - 1) * spacing
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
        let widthFromSpacing = self.spacing * CGFloat(self.cols - 1)
        let width = (sizeOfPuzzle.width - widthFromSpacing) / CGFloat(self.cols)
        
        let heightFromSpacing = self.spacing * CGFloat(self.rows - 1)
        let height = (sizeOfPuzzle.height - heightFromSpacing) / CGFloat(self.rows)
        
        return CGSize(width: width, height: height)
    }
    
    func originForPieceAt(row row: Int, col: Int) -> CGPoint {
        let size = self.sizeOfPiece
        let offset = CGVector(dx: (size.width + spacing) * CGFloat(col),
                              dy: (size.height + spacing) * CGFloat(row))
        
        return self.originOfPuzzle + offset
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
        guard let image = image else { return }
        let puzzle = Puzzle(rows: self.rows, cols: self.cols)
        let images = puzzle.createImages(from: image, multiplyByDeviceScale: false)
        
        images.forEach(self.addImageView)
        
        self.gestureRecognizers = nil
        self.addGestureRecognizers()
    }
    
    func addImageView(image image: UIImage, piece: PuzzlePiece, row: Int, col: Int) {
        let originOfPiece = self.originForPieceAt(row: row, col: col)
        let frame = CGRect(origin: originOfPiece, size: self.sizeOfPiece)
        
        let pieceView = PuzzlePieceView(frame: frame, piece: piece, pieceImage: image)
        self.addSubview(pieceView)
    }
    
    static var scaleForCurrentScreen: CGFloat {
        #if TARGET_INTERFACE_BUILDER
            return 2.0
        #else
            return UIScreen.mainScreen().scale
        #endif
    }
    
    
    //MARK: - User Interaction
    
    var pieceBeingPanned: PuzzlePieceView?
    
    func addGestureRecognizers() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.viewPanned(_:)))
        self.superview?.addGestureRecognizer(pan)
        
        self.dynamics = UIDynamicAnimator(referenceView: self)
    }
    
    func viewPanned(gestureRecognizer: UIPanGestureRecognizer) {
        let touch = gestureRecognizer.locationInView(self)
        let touchedSubviews = self.subviews.filter { $0.frame.contains(touch) }
        
        if gestureRecognizer.state == .Began, let pieceView = touchedSubviews.first as? PuzzlePieceView {
            self.pieceBeingPanned = pieceView
            self.bringSubviewToFront(pieceView)
            dynamics.removeAllBehaviors()
        }
        
        if let pieceView = self.pieceBeingPanned {
            
            let translation = gestureRecognizer.translationInView(self)
            pieceView.transform = CGAffineTransformMakeTranslation(translation.x, translation.y)
            
            if gestureRecognizer.state == .Ended {
                guard let piece = pieceView.piece, let row = piece.row, let col = piece.col else { return }
                
                //change translation to frame
                let totalTranslation = gestureRecognizer.translationInView(self).vectorFromOrigin()
                let newOrigin = pieceView.frame.origin + totalTranslation
                pieceView.frame.origin = newOrigin
                pieceView.transform = CGAffineTransformIdentity
                
                //snap to expected place
                let origin = self.originForPieceAt(row: row, col: col)
                let center = origin + CGVector(dx: pieceView.frame.width / 2,
                                               dy: pieceView.frame.height / 2)
                
                let snap = UISnapBehavior(item: pieceView, snapToPoint: center)
                snap.damping = 0.9
                dynamics.addBehavior(snap)
            }
        }
        
        
    }
    
}


//MARK: - Subview to manage individual pieces

class PuzzlePieceView : UIView {
    
    var piece: PuzzlePiece?
    var imageView: UIImageView?
    
    init(frame: CGRect, piece: PuzzlePiece, pieceImage: UIImage) {
        super.init(frame: frame)
        self.piece = piece
        
        self.clipsToBounds = false
        
        let width = frame.size.width
        let imageSize = piece.size(forWidth: width)
        let imageOffset = piece.imageOrigin(relativeTo: .zero, forWidth: width)
        
        let imageFrame = CGRect(origin: imageOffset, size: imageSize)
        self.imageView = UIImageView(frame: imageFrame)
        self.imageView!.image = pieceImage
        self.addSubview(imageView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}