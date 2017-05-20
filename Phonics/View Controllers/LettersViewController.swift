//
//  ViewController.swift
//  Phonetics
//
//  Created by Cal on 6/5/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class LettersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    
    //MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PHLetters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "letter", for: indexPath) as! LetterCell
        cell.decorateForLetter(PHLetters[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.bounds.width - 90) / 3
        return CGSize(width: width, height: width * 0.75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    //MARK: - User Interaction

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.view.isUserInteractionEnabled = false
        
        //animate selection
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            cell?.transform = CGAffineTransform(scaleX: 1.075, y: 1.075)
        }, completion: nil)
        
        //play audio for selection
        guard let letter = PHContent[PHLetters[indexPath.item]] else { return }
        letter.playSound()
         
        UAWhenDonePlayingAudio {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
                cell?.transform = CGAffineTransform.identity
                
                LetterViewController.present(for: letter, inController: self)
                self.view.isUserInteractionEnabled = true
                
            }, completion: nil)
        }
    }

}


class LetterCell : UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var letterIcon: UIImageView!
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var checkmark: UIButton!
    
    static var backgroundThread = DispatchQueue(label: "LetterCellBackground", qos: .background)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.masksToBounds = true
        cardView.clipsToBounds = true
    }
    
    func decorateForLetter(_ letter: String) {
        cardView.layer.cornerRadius = cardView.frame.height * 0.1
        letterLabel.text = letter.lowercased()
        
        guard let letter = PHContent[letter.uppercased()] else { return }
        
        //update image icon with correct image and aspect ratio
        let letterIconImage = letter.icon
        let aspectRatioToUse = max(1, letterIconImage.size.height / letterIconImage.size.width)
        
        letterIcon.removeConstraints(letterIcon.constraints)
        let newConstraint = letterIcon.heightAnchor.constraint(equalTo: letterIcon.widthAnchor, multiplier: aspectRatioToUse)
        newConstraint.priority = 900
        newConstraint.isActive = true
        
        letterIcon.image = letterIconImage
        layoutIfNeeded()
        
        //update progress bar
        let totalNumberOfPieces = 12 * letter.sounds.count
        
        let totalNumberOfOwnedPieces = letter.sounds.reduce(0) { previousResult, sound in
            let progress = Player.current.progress(forPuzzleNamed: sound.puzzleName)
            return previousResult + (progress?.numberOfOwnedPieces ?? 0)
        }
        
        progressBar.totalNumberOfSegments = totalNumberOfPieces
        progressBar.numberOfFilledSegments = totalNumberOfOwnedPieces
        
        checkmark.alpha = (totalNumberOfPieces == totalNumberOfOwnedPieces) ? 1.0 : 0.0
    }
    
}
