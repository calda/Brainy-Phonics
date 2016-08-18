//
//  PuzzleViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 8/18/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit

class PuzzleViewController : UIViewController {
    
    @IBOutlet weak var puzzleView: PuzzleView!
    
    
    //MARK: - Set up
    
    func configureForSound(sound: Sound) {
        guard let image = sound.puzzleImage else { return }
        puzzleView.image = image
        
        puzzleView.reload()
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func randomPuzzle(sender: UIButton) {
        let sound = PHContent.allSounds.random()
        
        if let sound = sound where sound.puzzleImage != nil {
            self.configureForSound(sound)
        } else {
            self.randomPuzzle(sender)
        }
        
    }
    
}