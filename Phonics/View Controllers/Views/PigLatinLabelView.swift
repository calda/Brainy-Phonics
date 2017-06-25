//
//  PigLatinLabelView.swift
//  Phonics
//
//  Created by Cal Stephens on 6/24/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

enum PigLatinLabelViewDisplayMode {
    case english, partialConstruction, fullConstruction, pigLatin
    
    var previous: PigLatinLabelViewDisplayMode? {
        switch(self) {
        case .english:
            return nil
        case .partialConstruction:
            return .english
        case .fullConstruction:
            return .partialConstruction
        case .pigLatin:
            return .fullConstruction
        }
    }
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
        stackView.constraintInCenterOfSuperview()
        
        switch(displayMode) {
        case .english:
            configureStackViewForEnglishMode()
        case .partialConstruction:
            configureStackViewForPartialConstructionMode()
        case .fullConstruction:
            configureStackViewForFullConstructionMode()
        case .pigLatin:
            configureStackViewForPigLatinMode()
        }
    }
        
    func configureStackViewForEnglishMode() {
        stackView.spacing = 5.0
        stackView.addArrangedSubview(buildFirstLetterLabel())
        stackView.addArrangedSubview(buildLabel(for: word.otherLetters))
    }
    
    func configureStackViewForPartialConstructionMode() {
        stackView.spacing = 50.0
        stackView.addArrangedSubview(buildLabel(for: word.otherLetters))
        stackView.addArrangedSubview(buildFirstLetterLabel())
    }
    
    func configureStackViewForFullConstructionMode() {
        stackView.spacing = 15.0
        stackView.addArrangedSubview(buildLabel(for: word.otherLetters))
        stackView.addArrangedSubview(buildLabel(for: "-"))
        stackView.addArrangedSubview(buildLabel(for: word.firstLetter))
        stackView.addArrangedSubview(buildLabel(for: "-"))
        stackView.addArrangedSubview(buildLabel(for: word.pigLatinEnding))
    }
    
    func configureStackViewForPigLatinMode() {
        stackView.spacing = 15.0
        stackView.addArrangedSubview(buildLabel(for: word.otherLetters))
        stackView.addArrangedSubview(buildLabel(for: "-"))
        stackView.addArrangedSubview(buildLabel(for: word.firstLetter + word.pigLatinEnding))
    }
    
    func buildFirstLetterLabel() -> UILabel {
        let label = PaddingLabel()
        label.font = font
        label.text = word.firstLetter
        label.backgroundColor = highlightColor
        
        label.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        
        return label
    }
    
    func buildLabel(for text: String) -> UILabel {
        let label = UILabel()
        label.font = font
        label.text = text
        label.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        return label
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
