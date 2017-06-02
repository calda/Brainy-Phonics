//
//  HomeViewController.swift
//  Phonetics
//
//  Created by Cal on 7/4/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController : UIViewController {
    
    @IBAction func presentEasyPhonics(_ sender: Any) {
        LettersViewController.present(from: self, with: .easyDifficulty)
    }
    
    @IBAction func presentStandardPhonics(_ sender: Any) {
        LettersViewController.present(from: self, with: .standardDifficulty)
    }
    
    @IBAction func presentPreKSightWords(_ sender: Any) {
        SightWordsViewController.present(from: self, using: PHContent.sightWordsPreK)
    }
    
    @IBAction func presentKindergartenSightWords(_ sender: Any) {
        SightWordsViewController.present(from: self, using: PHContent.sightWordsKindergarten)
    }
    
}
