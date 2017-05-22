//
//  SightWordsViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 5/21/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

class SightWordsViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    //MARK: - Presentation
    
    static let storyboardID = "sightWords"
    
    public static func present(from source: UIViewController, using sightWords: SightWordsManager) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardID) as! SightWordsViewController
        controller.sightWords = sightWords
        source.present(controller, animated: true, completion: nil)
    }
    
    
    var sightWords: SightWordsManager!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        self.view.backgroundColor = self.sightWords.category.color
    }
    
    
    //MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sightWords.words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sightWord = self.sightWords.words[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SightWordCell.identifier, for: indexPath) as! SightWordCell
        cell.decorate(for: sightWord)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = UIScreen.main.bounds.width - 90
        let width = totalWidth / 3
        return CGSize(width: width, height: width * 0.85)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    //MARK: - User Interaction
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.view.isUserInteractionEnabled = false
        
        //animate selection
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            cell?.transform = CGAffineTransform(scaleX: 1.075, y: 1.075)
        }, completion: nil)
        
        //play audio for selection
        let sightWord = self.sightWords.words[indexPath.item]
        print(sightWord.text)
    }
    
}


//MARK: - SightWordCell

class SightWordCell : UICollectionViewCell {
    
    static let identifier = "sightWord"
    static var backgroundThread = DispatchQueue(label: "SightWordCellBackground", qos: .background)
    
    @IBOutlet var cardView: UIView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var rightImageView: UIImageView!
    
    func decorate(for sightWord: SightWord) {
        self.cardView.layer.cornerRadius = self.cardView.frame.height * 0.1
        self.wordLabel.text = sightWord.text
        
        self.leftImageView.update(on: SightWordCell.backgroundThread, withImage: {
            return sightWord.sentence1.image
        })
        
        self.rightImageView.update(on: SightWordCell.backgroundThread, withImage: {
            return sightWord.sentence2.image
        })
    }
}
