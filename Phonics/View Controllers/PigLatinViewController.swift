//
//  PigLatinViewController.swift
//  Phonics
//
//  Created by Cal Stephens on 6/24/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

//MARK: - Content

enum PigLatinSlide {
    case image(UIImage)
    case text(String)
    case example(PigLatinWord, PigLatinLabelViewDisplayMode)
    
    private var targetImageWidth: CGFloat {
        return iPad() ? 600 : 400
    }
    
    private var font: UIFont {
        let fontSize: CGFloat = iPad() ? 60 : 45
        return UIFont(name: "ComicNeue-Bold", size: fontSize) ?? .systemFont(ofSize: fontSize)
    }
    
    private var highlightColor: UIColor {
        return #colorLiteral(red: 0.9069760508, green: 0.9069760508, blue: 0.9069760508, alpha: 1)
    }
    
    var view: UIView {
        switch(self) {
        case .image(let image):
            return BasicImageView(with: image, targetWidth: targetImageWidth)
        case .text(let text):
            return BasicLabelView(with: text, font: font)
        case .example(let word, let mode):
            return PigLatinLabelView(with: word, displayMode: mode, font: font, highlightColor: highlightColor)
        }
    }
}

struct PigLatinWord {
    static let dog = PigLatinWord(firstLetter: "d", otherLetters: "og", pigLatinEnding: "ay")
    static let cat = PigLatinWord(firstLetter: "c", otherLetters: "at", pigLatinEnding: "ay")
    
    let firstLetter: String
    let otherLetters: String
    let pigLatinEnding: String
}


//MARK: - PigLatinViewController

class PigLatinViewController: UIViewController {
    
    let slides: [TimeInterval : PigLatinSlide] = [
        0.0:    .image(#imageLiteral(resourceName: "logo-secret-stuff")),
        22.85:  .example(.dog, .english),
        25.20:  .example(.dog, .prefix),
        28.58:  .example(.dog, .partialConstruction),
        34.20:  .example(.dog, .pulse),
        40.00:  .example(.dog, .fullConstruction),
        45.42:  .example(.dog, .pigLatin),
        49.51:  .example(.dog, .sideBySide),
        52.03:  .example(.cat, .english),
        53.94:  .example(.cat, .prefix),
        56.63:  .example(.cat, .partialConstruction),
        61.03:  .example(.cat, .pulse),
        66.25:  .example(.cat, .fullConstruction),
        69.93:  .example(.cat, .pigLatin),
        71.40:  .example(.cat, .sideBySide),
        76.40:  .text("boy _ oy-bay"),
        80.83:  .text("girl _ irl-gay"),
        85.59:  .text(""),
        //these need to be redone
        92.27:  .text("mother"),
        95.49:  .text("other-may"),
        97.28:  .text("mother"),
        100.88: .text("other-may"),
        102.88: .text("father"),
        105.88: .text("ather-fay"),
        107.40: .text("father"),
        110.29: .text("ather-fay"),
        112.15: .text("teacher"),
        115.30: .text("eacher-tay"),
        116.95: .text("teacher"),
        119.60: .text("eacher-tay"),
        121.46: .text("school"),
        124.60: .text("ool-schay"),
        126.22: .text("school"),
        129.00: .text("ool-schay"),
        131.09: .text("brother"),
        133.39: .text("other-bray"),
        134.86: .text("sister"),
        137.78: .text("ister-say"),
    ]
    
    var timers = [Timer]()
    @IBOutlet weak var contentView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        let START_TIME = 92.0
        
        let DURATION = 301.0
        let AUDIO_INFO = (fileName: "pig latin content", wordStart: START_TIME, wordDuration: DURATION - START_TIME)
        PHContent.playAudioForInfo(AUDIO_INFO)
        
        for (time, slide) in slides {
            if time < START_TIME {
                continue
            }
            
            Timer.scheduleAfter(time - START_TIME, addToArray: &timers) {
                self.showSlide(slide)
            }
        }
    }
    
    func showSlide(_ slide: PigLatinSlide) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let newView = slide.view
        contentView.addSubview(newView)
        newView.constraintInCenterOfSuperview(requireHugging: false)
    }
    
}
