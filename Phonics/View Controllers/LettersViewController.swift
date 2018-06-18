//
//  ViewController.swift
//  Phonetics
//
//  Created by Cal on 6/5/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit


class LettersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    //MARK: - Presentation
    
    static let storyboardId = "letters"
    
    static func present(from source: UIViewController, with difficulty: Letter.Difficulty) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as! LettersViewController
        controller.difficulty = difficulty
        source.present(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Setup
    
    @IBOutlet weak var collectionView: UICollectionView!
    var difficulty: Letter.Difficulty!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        self.collectionView.backgroundColor = self.difficulty.color
    }
    
    
    //MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if difficulty == .easyDifficulty {
            return PHLetters.count
        }
        
        return PHContent.allPhonicsSorted.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "letter", for: indexPath) as! LetterCell
        if self.difficulty == .easyDifficulty {
            cell.decorateForLetter(PHLetters[indexPath.item], difficulty: difficulty)
        } else {
            let phonic = PHContent.allPhonicsSorted[indexPath.item]
            cell.decorateForLetter(phonic.displayString, difficulty: difficulty, sound: phonic)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frameInsetByMargins.width - 100) / 3
        return CGSize(width: width, height: width * 0.75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    //MARK: - User Interaction

    @IBAction func puzzleButtonPressed(_ sender: Any) {
        PuzzleCollectionViewController.present(with: difficulty, from: self)
    }
    
    @IBAction func quizButtonPressed(_ sender: Any) {
        QuizViewController.presentQuiz(customSound: nil, showingThreeWords: false, difficulty: self.difficulty, onController: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.view.isUserInteractionEnabled = false
        
        //animate selection
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            cell?.transform = CGAffineTransform(scaleX: 1.075, y: 1.075)
        }, completion: nil)
        
        func afterAudio(letter: Letter) {
            UAWhenDonePlayingAudio {
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
                    cell?.transform = CGAffineTransform.identity
                    
                    LetterViewController.present(for: letter, with: self.difficulty, inController: self)
                    self.view.isUserInteractionEnabled = true
                    
                }, completion: nil)
            }
        }
        
        //play audio for selection
        if self.difficulty == .easyDifficulty {
            guard let letter = PHContent[PHLetters[indexPath.item]] else { return }
            letter.playAudio()
            afterAudio(letter: letter)
        } else {
            //phonics
            let sound = PHContent.allPhonicsSorted[indexPath.item]
            sound.playAudio(withWords: false)
            let letter = Letter(text: PHContent.allPhonicsSorted[indexPath.item].sourceLetter, sounds: [sound])
            afterAudio(letter: letter)
        }
    }
}


class LetterCell : UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var letterIcon: UIImageView!
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var checkmark: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.masksToBounds = true
        cardView.clipsToBounds = true
        
        
    }
    
    func decorateForLetter(_ letterText: String, difficulty: Letter.Difficulty, sound: Sound? = nil) {
        cardView.layer.cornerRadius = cardView.frame.height * 0.1
        
        guard let firstLetter = letterText.first,
            let letter = PHContent[String(firstLetter).uppercased()] else { return }
        
        //decorates differently for either phonics or alphabet letters
        if difficulty == .easyDifficulty {
            //alphabet letters
            letterLabel.text = letterText.uppercased() + letterText.lowercased()
            
            let letterIconImage = letter.icon(for: difficulty)
            decorateIcon(letterIconImage: letterIconImage, letter: letter, difficulty: difficulty)
        } else {
            //phonics table of contents
            letterLabel.text = letterText.lowercased()
            letterLabel.textColor = sound?.color
            
            //phonic displays image of first primary word
            if let imageName = sound?.primaryWords[0].text, let letterIconImage = UIImage(named: "\(imageName).jpg") {
                decorateIcon(letterIconImage: letterIconImage, letter: letter, difficulty: difficulty, sound: sound)
            }
        }
        
    }
    
    //update image icon with correct image and aspect ratio
    func decorateIcon(letterIconImage: UIImage, letter: Letter, difficulty: Letter.Difficulty, sound: Sound? = nil) {
        let aspectRatioToUse = max(1, letterIconImage.size.height / letterIconImage.size.width)
        
        letterIcon.removeConstraints(letterIcon.constraints)
        let newConstraint = letterIcon.heightAnchor.constraint(equalTo: letterIcon.widthAnchor, multiplier: aspectRatioToUse)
        newConstraint.priority = UILayoutPriority(rawValue: 900)
        newConstraint.isActive = true
        
        letterIcon.image = letterIconImage
        layoutIfNeeded()
        
        //update progress bar. There are 12 pieces in a puzzle, One puzzle per sound.
        let totalNumberOfPieces = 12 * (difficulty == .standardDifficulty ? 1 : letter.sounds(for: difficulty).count)
        
        let totalNumberOfOwnedPieces: Int
        if difficulty == .standardDifficulty {
            guard let sound = sound else {return}
            let progress = Player.current.progress(forPuzzleNamed: sound.puzzleName)
            totalNumberOfOwnedPieces = progress?.numberOfOwnedPieces ?? 0
        } else {
            totalNumberOfOwnedPieces = letter.sounds(for: difficulty).reduce(0) { previousResult, sound in
                let progress = Player.current.progress(forPuzzleNamed: sound.puzzleName)
                return previousResult + (progress?.numberOfOwnedPieces ?? 0)
            }
        }
        
        
        progressBar.totalNumberOfSegments = totalNumberOfPieces
        progressBar.numberOfFilledSegments = totalNumberOfOwnedPieces
        
        checkmark.isHidden = totalNumberOfPieces != totalNumberOfOwnedPieces
    }
    
    
    
}
