//
//  SectionLabel.swift
//  HobbyQuest
//
//  Created by Monica Tran on 12/9/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit

extension UIViewController {
    func setGradientBackground() {
        let colorTop = UIColor(red: 90.0/255.0, green: 171.0/255.0, blue: 141.0/255.0, alpha: 1).cgColor
        let colorBottom = UIColor(red: 215.0/255.0, green: 235.0/255.0, blue: 217.0/255.0, alpha: 1).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 0.5]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIView {
    func setGradientBackground() {
        self.layer.backgroundColor = UIColor.clear.cgColor
        let colorTop = UIColor(red: 90.0/255.0, green: 171.0/255.0, blue: 141.0/255.0, alpha: 1).cgColor
        let colorBottom = UIColor(red: 90.0/255.0, green: 171.0/255.0, blue: 141.0/255.0, alpha: 0.5).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.locations = [0.0, 0.5]
        gradientLayer.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        //self.layer.addSublayer(gradientLayer)
    }
}
