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
    
    override func awakeFromNib() {
        self.createImageViews()
    }
    
    override func prepareForInterfaceBuilder() {
        self.createImageViews()
    }
    
    //MARK: - Layout Subviews
    
    func createImageViews() {
        guard let image = image else { return }
        let puzzle = Puzzle(rows: self.rows, cols: self.cols)
        let images = puzzle.createImages(from: image, multiplyByDeviceScale: false)
        
        images.forEach(self.addImageView)
    }
    
    func addImageView(image image: UIImage, piece: PuzzlePiece, row: Int, col: Int) {
        guard let sourceImage = self.image else { return }
        let deviceScale = PuzzleView.scaleForCurrentScreen
        let width = sourceImage.size.width / deviceScale / CGFloat(self.cols)
        let height = sourceImage.size.height / deviceScale / CGFloat(self.rows)
        
        let origin = CGPoint(x: (width + spacing) * CGFloat(col),
                             y: (height + spacing) * CGFloat(row))
        let frame = CGRect(origin: origin, size: CGSize(width: width, height: height))
        
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
    
    
}

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