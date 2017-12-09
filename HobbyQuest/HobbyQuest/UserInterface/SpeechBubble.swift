//
//  SectionLabel.swift
//  HobbyQuest
//
//  Created by Monica Tran on 12/9/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit

class SpeechBubble: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    //You can change the initial Section Label attributes here
    func initializeLabel() {
        
        //self.textAlignment = .left
        self.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        self.textColor = UIColor.darkText
        self.layer.shadowOffset = CGSize(width: -3.0, height: 1)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 6
        self.layer.cornerRadius = 20.0
        
        self.textInsets.left = 20
        self.textInsets.right = 20
    }
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
}
