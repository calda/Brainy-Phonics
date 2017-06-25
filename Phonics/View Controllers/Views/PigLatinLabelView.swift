//
//  PigLatinLabelView.swift
//  Phonics
//
//  Created by Cal Stephens on 6/24/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

class PigLatinLabelView: UIView {
    
    let stackView: UIStackView
    let word: PigLatinWord
    let font: UIFont
    let highlightColor: UIColor
    
    init(with word: PigLatinWord, font: UIFont, highlightColor: UIColor) {
        stackView = UIStackView()
        self.font = font
        self.word = word
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
        stackView.spacing = 20.0
        stackView.constraintInCenterOfSuperview()
        
        stackView.addArrangedSubview(buildFirstLetterLabel())
        stackView.addArrangedSubview(buildOtherLettersLabel())
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
    
    func buildOtherLettersLabel() -> UILabel {
        let label = UILabel()
        label.font = font
        label.text = word.otherLetters
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
