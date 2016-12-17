//
//  ViewController.swift
//  Phonetics
//
//  Created by Cal on 6/5/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class LettersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("LOADED PHCONTENT \(PHContent)")
        return PHLetters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "letter", for: indexPath) as! LetterCell
        cell.decorateForLetter(PHLetters[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.bounds.width - 90) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    //MARK: - User Interaction
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        self.view.isUserInteractionEnabled = false
        
        //animate selection
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            cell?.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: nil)
        
        //play audio for selection
        guard let letter = PHContent[PHLetters[indexPath.item]] else { return true }
        letter.playSound()
        
        UAWhenDonePlayingAudio {
            //recursively call with a nonexistant index to hide the cell
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
                cell?.transform = CGAffineTransform.identity
                
                LetterViewController.presentForLetter(letter, inController: self)
                self.view.isUserInteractionEnabled = true
                
            }, completion: nil)
        }
        
        return true
    }


}


class LetterCell : UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var letterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.masksToBounds = true
        cardView.clipsToBounds = true
    }
    
    func decorateForLetter(_ letter: String) {
        
        cardView.layer.cornerRadius = cardView.frame.width * 0.2
        letterLabel.text = letter
        
    }
    
}
