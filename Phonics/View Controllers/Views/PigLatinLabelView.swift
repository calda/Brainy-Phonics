//
//  PigLatinLabelView.swift
//  Phonics
//
//  Created by Cal Stephens on 6/24/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

enum AnimationSetting {
    case animated, notAnimated
    
    var shouldAnimate: Bool {
        return self == .animated
    }
}

enum PigLatinLabelViewDisplayMode {
    case english, prefix, pulse, partialConstruction, fullConstruction, pigLatin, sideBySide(AnimationSetting)
}

class PigLatinLabelView: UIView {
    
    let stackView: UIStackView
    let word: PigLatinWord
    let displayMode: PigLatinLabelViewDisplayMode
    let font: UIFont
    let highlightColor: UIColor
    
    init(with word: PigLatinWord,
         displayMode: PigLatinLabelViewDisplayMode,
         font: UIFont, highlightColor: UIColor)
    {
        stackView = UIStackView()
        self.font = font
        self.word = word
        self.displayMode = displayMode
        self.highlightColor = highlightColor
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        setUpStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func setUpStackView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        guard let constraints = stackView.constraintInCenterOfSuperview() else {
            return
        }
        
        switch(displayMode) {
        case .english:
            configureStackViewForEnglishMode(centerConstraint: constraints.centerX)
        case .prefix:
            configureStackViewForPrefixMode(centerConstraint: constraints.centerX)
        case .pulse:
            configureStackViewForPulseMode()
        case .partialConstruction:
            configureStackViewForPartialConstructionMode()
        case .fullConstruction:
            configureStackViewForFullConstructionMode()
        case .pigLatin:
            configureStackViewForPigLatinMode()
        case .sideBySide(let animationSetting):
            configureStackViewForSideBySideMode(animate: animationSetting.shouldAnimate)
        }
    }
    
    //MARK: - English mode
    
    func configureStackViewForEnglishMode(centerConstraint: NSLayoutConstraint) {
        //setup
        let firstLetterLabel = buildFirstLetterLabel()
        firstLetterLabel.layer.backgroundColor = UIColor.clear.cgColor
        stackView.spacing = -7 //account for the extra padding in the firstLetterLabel
        
        centerConstraint.constant = -3.5
        stackView.layoutIfNeeded()
        
        stackView.addArrangedSubview(firstLetterLabel)
        stackView.addArrangedSubview(buildLabel(for: word.otherLetters))
    }
    
    //MARK: - Prefix Mode
    
    func configureStackViewForPrefixMode(centerConstraint: NSLayoutConstraint) {
        //setup
        let firstLetterLabel = buildFirstLetterLabel()
        firstLetterLabel.layer.backgroundColor = UIColor.clear.cgColor
        stackView.spacing = -7 //account for the extra padding in the firstLetterLabel
        
        centerConstraint.constant = -3.5
        stackView.layoutIfNeeded()
        
        stackView.addArrangedSubview(firstLetterLabel)
        stackView.addArrangedSubview(buildLabel(for: word.otherLetters))
        
        //animate
        delay(0.02) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.stackView.spacing = 25.0
                centerConstraint.constant = 0
                self.stackView.layoutIfNeeded()
            }, completion: nil)
            
            UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
                firstLetterLabel.layer.backgroundColor = self.highlightColor.cgColor
            }, completion: nil)
        }
    }
    
    //MARK: - Partial Construction
    
    func configureStackViewForPartialConstructionMode() {
        //setup
        stackView.spacing = 25.0
        let leftFirstLetterlabel = buildFirstLetterLabel()
        let otherLettersLabel = buildLabel(for: word.otherLetters)
        let rightFirstLetterLabel = buildFirstLetterLabel()
        
        stackView.addArrangedSubview(leftFirstLetterlabel)
        stackView.addArrangedSubview(otherLettersLabel)
        stackView.addArrangedSubview(rightFirstLetterLabel)
        
        rightFirstLetterLabel.isHidden = true
        
        //animate
        delay(0.02) {
            self.layoutIfNeeded()
            
            let initialFirstLetterFrame = self.convert(leftFirstLetterlabel.bounds, from: leftFirstLetterlabel)
            
            //something about this animation is just awful -- i don't understand why it needs to work like this
            //where does the 12 come from??????? 25/2??? i don't understand.
            //but it works on iOS 10 / iOS 11 and iPhone 6 / iPad so I'm gonna call it good enough
            let horizontalTranslation = self.frame.origin.x + self.stackView.frame.origin.x + otherLettersLabel.frame.width + 25 + 12
            
            leftFirstLetterlabel.alpha = 0.0
            rightFirstLetterLabel.alpha = 0.0
            
            //animate temporary label in arc
            let temporaryLabel = self.buildFirstLetterLabel()
            self.addSubview(temporaryLabel)
            temporaryLabel.frame = initialFirstLetterFrame
            
            UIView.animate(withDuration: 0.7, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState, .allowAnimatedContent], animations: {
                temporaryLabel.transform = CGAffineTransform(translationX: horizontalTranslation, y: 0)
            }, completion: nil)
            
            UIView.animate(withDuration: 0.35, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState, .allowAnimatedContent], animations: {
                temporaryLabel.frame.origin.y = initialFirstLetterFrame.origin.y - 45
            }, completion: nil)
            
            UIView.animate(withDuration: 0.35, delay: 0.35, options: [.curveEaseInOut, .beginFromCurrentState, .allowAnimatedContent], animations: {
                temporaryLabel.frame.origin.y = initialFirstLetterFrame.origin.y
            }, completion: nil)
            
            UIView.animate(withDuration: 0.7, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.stackView.spacing = 50.0
                leftFirstLetterlabel.isHidden = true
                rightFirstLetterLabel.isHidden = false
                self.stackView.layoutIfNeeded()
            }, completion: { _ in
                rightFirstLetterLabel.alpha = 1.0
                temporaryLabel.removeFromSuperview()
            })
        }
    }
    
    //MARK: - Pulse
    
    func configureStackViewForPulseMode() {
        //setup
        let otherLettersLabel = buildLabel(for: word.otherLetters)
        let firstLetterLabel = buildFirstLetterLabel()
        
        stackView.spacing = 50
        stackView.addArrangedSubview(otherLettersLabel)
        stackView.addArrangedSubview(firstLetterLabel)
        
        //animate
        otherLettersLabel.pulseToSize(size: 1.2, growFor: 0.5, shrinkFor: 0.6)
    }
    
    //MARK: - Full Construction Mode
    
    func configureStackViewForFullConstructionMode() {
        //setup
        let otherLettersLabel = buildLabel(for: word.otherLetters)
        let firstDashLabel = buildLabel(for: "-")
        let firstLetterLabel = buildFirstLetterLabel()
        let secondDashLabel = buildLabel(for: "-")
        let endingLabel = buildLabel(for: word.pigLatinEnding)
        
        stackView.spacing = 50
        stackView.addArrangedSubview(otherLettersLabel)
        stackView.addArrangedSubview(firstDashLabel)
        stackView.addArrangedSubview(firstLetterLabel)
        stackView.addArrangedSubview(secondDashLabel)
        stackView.addArrangedSubview(endingLabel)
        
        for view in [firstDashLabel, secondDashLabel, endingLabel] {
            view.isHidden = true
            view.alpha = 0.0
        }
        
        delay(0.02) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.stackView.spacing = 10.0
                
                for view in [firstDashLabel, secondDashLabel, endingLabel] {
                    view.isHidden = false
                    view.alpha = 1.0
                }
            }, completion: nil)
            
            UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
                firstLetterLabel.layer.backgroundColor = UIColor.clear.cgColor
            }, completion: nil)
        }
    }
    
    //MARK: - Pig Latin Mode
    
    func configureStackViewForPigLatinMode() {
        //setup
        let otherLettersLabel = buildLabel(for: word.otherLetters)
        let firstDashLabel = buildLabel(for: "-")
        let firstLetterLabel = buildFirstLetterLabel()
        let secondDashLabel = buildLabel(for: "-")
        let endingLabel = buildLabel(for: word.pigLatinEnding)
        
        let paddingBetweenOtherLettersAndDash = buildPaddingView(width: 6 + 7)
        let paddingBetweenDashAndFirstLetter = buildPaddingView(width: 6)
        
        stackView.spacing = 10
        stackView.addArrangedSubview(otherLettersLabel)
        stackView.addArrangedSubview(paddingBetweenOtherLettersAndDash)
        stackView.addArrangedSubview(firstDashLabel)
        stackView.addArrangedSubview(paddingBetweenDashAndFirstLetter)
        stackView.addArrangedSubview(firstLetterLabel)
        stackView.addArrangedSubview(secondDashLabel)
        stackView.addArrangedSubview(endingLabel)
        
        paddingBetweenDashAndFirstLetter.isHidden = true
        paddingBetweenOtherLettersAndDash.isHidden = true
        firstLetterLabel.layer.backgroundColor = UIColor.clear.cgColor
        
        delay(0.02) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.stackView.spacing = -7
                
                paddingBetweenDashAndFirstLetter.isHidden = false
                paddingBetweenOtherLettersAndDash.isHidden = false
                secondDashLabel.isHidden = true
            }, completion: nil)
        }
    }
    
    //MARK: - Side By Side mode
    
    func configureStackViewForSideBySideMode(animate shouldAnimate: Bool) {
        //setup
        let englishLabel = buildLabel(for: word.firstLetter + word.otherLetters)
        let otherLettersLabel = buildLabel(for: word.otherLetters)
        let firstDashLabel = buildLabel(for: "-")
        let firstLetterLabel = buildFirstLetterLabel()
        let endingLabel = buildLabel(for: word.pigLatinEnding)
        
        let paddingBetweenEnglishAndPigLatin = buildPaddingView(width: 80)
        let paddingBetweenOtherLettersAndDash = buildPaddingView(width: 6 + 7)
        let paddingBetweenDashAndFirstLetter = buildPaddingView(width: 6)
        
        stackView.spacing = -7
        
        stackView.addArrangedSubview(englishLabel)
        stackView.addArrangedSubview(paddingBetweenEnglishAndPigLatin)
        stackView.addArrangedSubview(otherLettersLabel)
        stackView.addArrangedSubview(paddingBetweenOtherLettersAndDash)
        stackView.addArrangedSubview(firstDashLabel)
        stackView.addArrangedSubview(paddingBetweenDashAndFirstLetter)
        stackView.addArrangedSubview(firstLetterLabel)
        stackView.addArrangedSubview(endingLabel)
        
        englishLabel.isHidden = true
        englishLabel.alpha = 0.0
        paddingBetweenEnglishAndPigLatin.isHidden = true
        firstLetterLabel.layer.backgroundColor = UIColor.clear.cgColor
        
        //animate
        
        let animations = {
            englishLabel.isHidden = false
            englishLabel.alpha = 1.0
            paddingBetweenEnglishAndPigLatin.isHidden = false
        }
        
        if shouldAnimate {
            delay(0.02) {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: animations, completion: nil)
            }
        } else {
            animations()
        }
    }
    
    //MARK: - Helpers
    
    func buildFirstLetterLabel() -> PaddingLabel {
        let label = PaddingLabel()
        label.font = font
        label.text = word.firstLetter
        label.layer.backgroundColor = highlightColor.cgColor
        
        label.setContentHuggingPriority(.required, for: .vertical)
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        
        return label
    }
    
    func buildLabel(for text: String) -> UILabel {
        let label = UILabel()
        label.font = font
        label.text = text
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }
    
    func buildPaddingView(width: CGFloat) -> UIView {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        return view
    }
}


// used for background color around label

@IBDesignable class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}
