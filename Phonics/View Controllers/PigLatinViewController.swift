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
    case number(String)
    case funText(String)
    case example(PigLatinWord, PigLatinLabelViewDisplayMode)
    case dismiss
    
    private var targetImageWidth: CGFloat {
        return iPad() ? 600 : 400
    }
    
    private var font: UIFont {
        let fontSize: CGFloat
        switch(self) {
        case .number(_):
            fontSize = iPad() ? 133 : 100
        default:
            fontSize = iPad() ? 60 : 45
        }
        return UIFont(name: "ComicNeue-Bold", size: fontSize) ?? .systemFont(ofSize: fontSize)
    }
    
    private var highlightColor: UIColor {
        return #colorLiteral(red: 0.9069760508, green: 0.9069760508, blue: 0.9069760508, alpha: 1)
    }
    
    var view: UIView? {
        switch(self) {
        case .image(let image):
            return BasicImageView(with: image, targetWidth: targetImageWidth)
        case .text(let text):
            return BasicLabelView(with: text, font: font)
        case .number(let text):
            return BasicLabelView(with: text, font: font)
        case .example(let word, let mode):
            return PigLatinLabelView(with: word, displayMode: mode, font: font, highlightColor: highlightColor)
        case .funText(let text):
            let view = BasicLabelView(with: text, font: font)
            pivotView(view)
            return view
        case .dismiss:
            return nil
        }
    }
}

struct PigLatinWord {
    static let dog = PigLatinWord(firstLetter: "d", otherLetters: "og", pigLatinEnding: "ay")
    static let cat = PigLatinWord(firstLetter: "c", otherLetters: "at", pigLatinEnding: "ay")
    static let boy = PigLatinWord(firstLetter: "b", otherLetters: "oy", pigLatinEnding: "ay")
    static let girl = PigLatinWord(firstLetter: "g", otherLetters: "irl", pigLatinEnding: "ay")
    
    let firstLetter: String
    let otherLetters: String
    let pigLatinEnding: String
}


//MARK: - PigLatinViewController

class PigLatinViewController: UIViewController {
    
    
    //MARK: Presentation
    
    static func present(from source: UIViewController) {
        let pigLatin = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pig latin") as! PigLatinViewController
        source.present(pigLatin, animated: true, completion: nil)
    }
    
    
    //MARK: Slides
    //todo make times exact- will need mp3 file.
    let slides: [TimeInterval : PigLatinSlide] = [
        0.0:    .image(#imageLiteral(resourceName: "logo-secret-stuff")),
        6.0:    .image(#imageLiteral(resourceName: "Grouped-Pig-Latin")),
        12.50:  .image(#imageLiteral(resourceName: "eight_kids")),
        22.15:  .example(.dog, .english),
        24.61:  .example(.dog, .prefix),
        28.00:  .example(.dog, .partialConstruction),
        33.36:  .example(.dog, .pulse),
        39.11:  .example(.dog, .fullConstruction),
        43.20:  .example(.dog, .pigLatin),
        47.93:  .example(.dog, .sideBySide(.animated)),
        52.54:  .example(.cat, .english),
        54.30:  .example(.cat, .prefix),
        56.77:  .example(.cat, .partialConstruction),
        61.26:  .example(.cat, .pulse),
        66.68:  .example(.cat, .fullConstruction),
        70.49:  .example(.cat, .pigLatin),
        71.88:  .example(.cat, .sideBySide(.animated)),
        77.15:  .example(.boy, .sideBySide(.notAnimated)),
        81.40:  .example(.girl, .sideBySide(.notAnimated)),
        86.27:  .text("mother"),
        96.19:  .text("other-may"),
        97.98:  .text("mother"),
        101.64: .text("other-may"),
        103.50: .text("father"),
        106.70: .text("ather-fay"),
        108.09: .text("father"),
        110.95: .text("ather-fay"),
        112.89: .text("teacher"),
        116.00: .text("eacher-tay"),
        117.61: .text("teacher"),
        120.28: .text("eacher-tay"),
        122.19: .text("school"),
        125.30: .text("ool-schay"),
        126.69: .text("school"),
        129.51: .text("ool-schay"),
        131.53: .text("brother"),
        134.09: .text("other-bray"),
        135.33: .text("sister"),
        138.45: .text("ister-say"),
        140.06: .text("ood-gay ob-jay!"),
        142.11: .text("Good job!"),
        143.46: .text("an-cay"),
        144.52: .text("an-cay ou-yay"),
        145.62: .text("an-cay ou-yay alk-tay"),
        146.90: .text("an-cay ou-yay alk-tay ig-pay"),
        148.15: .text("an-cay ou-yay alk-tay ig-pay atin-lay?"),
        150.05: .text("Can you talk pig latin?"),
        152.40: .text("es-yay"),
        153.57: .text("es-yay ou-yay"),
        154.70: .text("es-yay ou-yay an-can"),
        155.77: .text("es-yay ou-yay an-cay alk-tay"),
        156.97: .text("es-yay ou-yay an-cay alk-tay ig-pay"),
        158.26: .text("es-yay ou-yay an-cay alk-tay ig-pay atin-lay!"),
        159.35: .text("ood-gay ob-jay!"),
        161.70: .text("Good job!"),
        163.62: .text("o    u    a    e    i"),
        185.02: .text("is"),
        188.10: .text("is-ay"),
        189.34: .text("am"),
        192.20: .text("am-ay"),
        193.57: .text("I am a good talker."),
        198.50: .text("I-ay am-ay a-ay ood-gay alker-tay."),
        204.20: .number("1    2    3"),
        211.39: .number("1"),
        213.98: .number("2"),
        217.06: .number("3"),
        220.06: .number("4"),
        223.14: .number("5"),
        226.65: .number("6"),
        230.32: .number("7"),
        233.17: .number("8"),
        236.17: .number("9"),
        239.21: .number("10"),
        242.07: .text("ood-gay!"),
        243.42: .text("errific-tay!"),
        245.00: .text("onderful-way!"),
        246.32: .text("ou-yay an-cay alk-tay ig-pay atin-lay!"),
        251.46: .text("You can talk in pig latin!"),
        265.61: .funText("ood-gay uck-lay!"),
        267.77: .funText("Good luck!"),
        269.35: .funText("And-ay ave-hay un-fay!"),
        272.42: .funText("🎉  🎉  🎉"),
        274.42: .funText("🎉  🎉  🎉"),
        276.42: .funText("🎉  🎉  🎉"),
        278.42: .funText("🎉  🎉  🎉"),
        279.49: .dismiss
    ]
    
    
    //MARK: Playback
    
    var timers = [Timer]()
    @IBOutlet weak var contentView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.showSlide(.image(#imageLiteral(resourceName: "logo-secret-stuff")))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let START_TIME: Double = 0
        
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
        
        if let newView = slide.view {
            contentView.addSubview(newView)
            newView.constraintInCenterOfSuperview(requireHugging: false)
        }
        
        if case .dismiss = slide {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UAHaltPlayback()
        self.timers.forEach { $0.invalidate() }
    }
    
}
