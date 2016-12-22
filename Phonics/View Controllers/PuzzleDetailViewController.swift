//
//  PuzzleDetailViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 12/19/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class PuzzleDetailViewController : UIViewController {
    
    @IBOutlet weak var puzzleView: PuzzleView!
    @IBOutlet weak var scrim: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    var oldPuzzleView: PuzzleView!
    var animationImage: UIImageView!
    var sound: Sound!
    
    
    //MARK: - Presentation
    
    static func present(for sound: Sound, from puzzleView: PuzzleView, in source: UIViewController) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let puzzleDetail = storyboard.instantiateViewController(withIdentifier: "puzzle detail") as? PuzzleDetailViewController else { return }
        
        puzzleDetail.oldPuzzleView = puzzleView
        puzzleDetail.sound = sound
        
        puzzleDetail.modalPresentationStyle = .overCurrentContext
        puzzleDetail.modalTransitionStyle = .coverVertical
        
        source.present(puzzleDetail, animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.alpha = 0.0
        scrim.alpha = 0.0
        puzzleView.alpha = 0.0
        
        if let oldPuzzle = self.oldPuzzleView {
            puzzleView.puzzleName = oldPuzzle.puzzleName
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //create image and then animate
        guard let oldPuzzleView = self.oldPuzzleView else { return }
        let translatedFrame = self.view.convert(oldPuzzleView.bounds, from: oldPuzzleView)
        
        self.animationImage = UIImageView(image: puzzleView.asImage)
        
        animationImage.frame = translatedFrame
        self.view.addSubview(animationImage)
        oldPuzzleView.alpha = 0.0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            
            self.backButton.alpha = 1.0
            self.scrim.alpha = 1.0
            
            let newHeight = self.view.frame.height * 0.9
            let aspectRatio = self.animationImage.frame.width / self.animationImage.frame.height
            let newWidth = newHeight * aspectRatio
            self.animationImage.frame.size = CGSize(width: newWidth, height: newHeight)
            
            self.animationImage.center = self.view.center
            
        }, completion: { _ in
            
            self.puzzleView.alpha = 1.0
            
            UIView.animate(withDuration: 0.225, delay: 0.0, options: [], animations: {
                self.animationImage.alpha = 0.0
            }, completion: nil)
        })
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func backTapped(_ sender: Any) {
        
        self.puzzleView.alpha = 0.0
        self.animationImage.alpha = 1.0
        
        //grab new image
        self.animationImage.image = self.oldPuzzleView.asImage
        
        //animate
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
        
            guard let oldPuzzleView = self.oldPuzzleView else { return }
            let translatedFrame = self.view.convert(oldPuzzleView.bounds, from: oldPuzzleView)
            self.animationImage.frame = translatedFrame
            
            self.scrim.alpha = 0.0
            self.backButton.alpha = 0.0
        
        }, completion: { _ in
            self.oldPuzzleView.alpha = 1.0
            self.dismiss(animated: false, completion: nil)
        })
    }
    
}


extension UIView {
 
    var asImage: UIImage? {
        let previousAlpha = self.alpha
        self.alpha = 1.0
        
        UIGraphicsBeginImageContext(self.frame.size)
        
        let deviceScale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, deviceScale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        self.alpha = previousAlpha
        return image
    }
    
}



