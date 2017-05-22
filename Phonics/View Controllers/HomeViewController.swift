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
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        return
    }
    
    @IBAction func presentPreKSightWords(_ sender: Any) {
        SightWordsViewController.present(from: self, using: PHContent.sightWordsPreK)
    }
    
    @IBAction func presentKindergartenSightWords(_ sender: Any) {
        SightWordsViewController.present(from: self, using: PHContent.sightWordsKindergarten)
    }
    
}
