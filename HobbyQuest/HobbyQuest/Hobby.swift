//
//  Hobby.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/13/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(colorImage, for: forState)
    }}

class Hobby {
    let key:Any
    let category:String
    let cost:String
    let hobbyName:String
    let time:String
    let description:String
    let postImage:String
    let wikiHowLink:String

    init(snap: DataSnapshot) {
        key = snap.key
        
        let value = snap.value as? NSDictionary
        description = value?["details"] as? String ?? ""
        category = value?["category"] as? String ?? ""
        cost = value?["cost"] as? String ?? ""
        hobbyName = value?["hobbyName"] as? String ?? ""
        time = value?["time"] as? String ?? ""
        postImage = value?["postImage"] as? String ?? ""
        wikiHowLink = value?["wikiHowLink"] as? String ?? ""

    }
    init() {
        description = ""
        key = ""
        category = ""
        cost = ""
        hobbyName = ""
        time = ""
        postImage = ""
        wikiHowLink = ""
    }
}
