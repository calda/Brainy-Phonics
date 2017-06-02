//
//  PuzzleCollectionViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 1/7/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

class PuzzleCollectionViewController : UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    //MARK: - Presentation
    
    static let storyboardId = "puzzles"
    
    static func present(with difficulty: Letter.Difficulty, from source: UIViewController) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as! PuzzleCollectionViewController
        controller.difficulty = difficulty
        source.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - Setup
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonArea: UIView!
    
    var difficulty: Letter.Difficulty!
    var soundsWithCompletedPuzzles = [Sound]()
    var soundsWithIncompletePuzzles = [Sound]()
    
    lazy var cellSize: CGSize = {
        let height = (self.view.frame.height / 2) - 32
        let width = height * (3/4)
        return CGSize(width: width, height: height)
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        (soundsWithCompletedPuzzles, soundsWithIncompletePuzzles) = Player.current.soundsByPuzzleCompletion(with: difficulty)
        self.collectionView.reloadData()
        self.buttonArea.backgroundColor = difficulty.color
    }
    
    
    //MARK: - Collection View Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return self.soundsWithCompletedPuzzles.count }
        else { return self.soundsWithIncompletePuzzles.count }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "puzzle", for: indexPath)
        
        if let cell = cell as? PuzzleCollectionCell {
            
            //completed puzzles
            if indexPath.section == 0 {
                let sound = soundsWithCompletedPuzzles[indexPath.item]
                cell.decorate(for: sound, complete: true)
            }
            
            //incomplete puzzles
            else {
                let sound = soundsWithIncompletePuzzles[indexPath.item]
                cell.decorate(for: sound, complete: false)
            }
            
        }
        
        return cell
    }
    
    
    //MARK: - Collection View Flow Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let completedSectionIsEmpty = (self.collectionView(collectionView, numberOfItemsInSection: 0) == 0)
        
        if section == 0 {
            let right: CGFloat = (completedSectionIsEmpty) ? 0 : 10
            return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: right)
        }
        
        if section == 1 {
            let left: CGFloat = (completedSectionIsEmpty) ? 0 : 30
            return UIEdgeInsets(top: 20, left: left, bottom: 20, right: 20)
        }
        
        else { return .zero }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func backPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //completed puzzles
        if indexPath.section == 0 {
            guard let cell = collectionView.cellForItem(at: indexPath) as? PuzzleCollectionCell else { return }
            let sound = self.soundsWithCompletedPuzzles[indexPath.item]
            
            //make sure the cell doesn't overlap the bar on the left
            let puzzleFrame = self.view.convert(cell.puzzleImage.bounds, from: cell.puzzleImage)
            let collectionViewLeft = self.collectionView.frame.minX
            let difference = puzzleFrame.minX - collectionViewLeft
            
            let presentNow = {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    cell.cornerLabelView.alpha = 0.0
                })
                
                PuzzleDetailViewController.present(for: sound, from: cell.puzzleImage, withPuzzleShadow: cell.puzzleShadow, in: self, onDismiss: {
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.cornerLabelView.alpha = 1.0
                    })
                })
            }
            
            if difference < 0 {
                let newOffset = CGPoint(x: self.collectionView.contentOffset.x - abs(difference) - 15, y: 0)
                self.collectionView.setContentOffset(newOffset, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(325), execute: {
                    presentNow()
                })
            } else {
                presentNow()
            }
        }
        
        //incomplete puzzles
        else {
            let sound = self.soundsWithIncompletePuzzles[indexPath.item]
            guard let letter = PHContent[sound.sourceLetter] else { return }
            LetterViewController.present(for: letter, with: .standardDifficulty, inController: self, initialSound: sound)
        }
        
    }
    
    
}

class PuzzleCollectionCell : UICollectionViewCell {
    
    static let backgroundQueue = DispatchQueue(label: "PuzzleCollectionCell.backgroundQueue", qos: .background)
    
    @IBOutlet weak var puzzleImage: UIImageView!
    @IBOutlet weak var puzzleShadow: UIView!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var cornerLabelView: UIView!
    @IBOutlet weak var cornerLabel: UILabel!
    
    func decorate(for sound: Sound, complete: Bool) {
        
        if complete {
            self.alpha = 0.0 //will fade in once images loads
            self.puzzleImage.alpha = 1.0
            
            self.soundLabel.alpha = 0.0
            self.cornerLabelView.alpha = 1.0
            self.cornerLabel.text = sound.displayString.lowercased()
            
            PuzzleCollectionCell.backgroundQueue.async {
                //this might be a little fragile
                //the completed image only exists if the user has previously viewed
                //the PuzzleDetailController on this device. (AKA has completed the puzzle)
                let image = Puzzle.completedImage(forPuzzleNamed: sound.puzzleName)
                
                DispatchQueue.main.sync {
                    self.puzzleImage.image = image
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.alpha = 1.0
                    })
                }
            }
        }
        
        else {
            self.alpha = 1.0
            self.puzzleImage.alpha = 0.0
            
            self.soundLabel.alpha = 1.0
            self.cornerLabelView.alpha = 0.0
            self.soundLabel.text = sound.displayString.lowercased()
            return
        }
    }
    
}
