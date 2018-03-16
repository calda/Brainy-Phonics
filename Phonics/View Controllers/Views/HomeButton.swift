//
//  HomeButton.swift
//  Phonics
//
//  Created by Cal Stephens on 5/26/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

class HomeButton : UIButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(homeButtonPressed), for: [.touchUpInside])
    }
    
    @objc func homeButtonPressed() {
        HomeButton.returnToHomeViewController()
    }
    
    static func returnToHomeViewController() {
        guard let root = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        guard let home = root.presentedViewController as? HomeViewController else {
            return
        }

        UAHaltPlayback()
        home.dismiss(animated: true, completion: nil) //doesn't have the best animation but it works
    }
    
}
