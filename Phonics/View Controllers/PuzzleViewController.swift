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
    
    func configureForSound(_ sound: Sound) {
        puzzleView.puzzleName = sound.puzzleName
        puzzleView.reload()
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func randomPuzzle(_ sender: UIButton) {
        let sound = PHContent.allSounds.random()
        
        if let sound = sound {
            self.configureForSound(sound)
        } else {
            self.randomPuzzle(sender)
        }
        
    }
    
    @IBAction func togglePieces(_ sender: UIButton) {
        let text: String
        
        if sender.titleLabel!.text!.contains("Attach") {
            puzzleView.spacing = 0.0
            text = "Detach Pieces"
        } else {
            puzzleView.spacing = 20.0
            text = "Attach Pieces"
        }
        
        sender.setTitle(text, for: UIControlState())
        puzzleView.reload()
    }
}
