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
    case example(PigLatinWord)
    
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
        case .example(let word):
            return PigLatinLabelView(with: word, font: font, highlightColor: highlightColor)
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
        0.0: .image(#imageLiteral(resourceName: "logo-secret-stuff")),
        2.0: .text("dog"),
        4.0: .example(.dog),
        6.0: .text("dog _ og-day")
    ]
    
    var timers = [Timer]()
    @IBOutlet weak var contentView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        for (time, slide) in slides {
            Timer.scheduleAfter(time, addToArray: &timers) {
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
