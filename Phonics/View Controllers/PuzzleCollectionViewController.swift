//
//  PuzzleCollectionViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 1/7/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

class PuzzleCollectionViewController : UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    let soundsWithCompletedPuzzles = Player.current.soundsWithCompletedPuzzles
    
    lazy var cellSize: CGSize = {
        let height = self.view.frame.height
        let width = height * (3/4)
        return CGSize(width: width, height: height)
    }()
    
    
    //MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return soundsWithCompletedPuzzles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "puzzle", for: indexPath)
        
        if let cell = cell as? PuzzleCollectionCell {
            let sound = soundsWithCompletedPuzzles[indexPath.item]
            cell.decorate(for: sound)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func homePressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

class PuzzleCollectionCell : UICollectionViewCell {
    
    static let backgroundQueue = DispatchQueue(label: "PuzzleCollectionCell.backgroundQueue", qos: .background)
    
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var puzzleImage: UIImageView!
    
    func decorate(for sound: Sound) {
        
        soundLabel.text = sound.displayString.lowercased()
        
        self.puzzleImage.alpha = 0.0
        
        PuzzleCollectionCell.backgroundQueue.async {
            //this might be a little fragile
            //the completed image only exists if the user has previously viewed
            //the PuzzleDetailController on this device. (AKA has completed the puzzle)
            let image = Puzzle.completedImage(forPuzzleNamed: sound.puzzleName)
            
            DispatchQueue.main.sync {
                self.puzzleImage.image = image
                self.puzzleImage.alpha = 1.0
            }
        }
        
    }
    
}
