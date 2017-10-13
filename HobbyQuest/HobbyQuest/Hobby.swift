//
//  Hobby.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/13/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Hobby {
    let key:Any
    let category:String
    let cost:String
    let hobbyName:String
    let time:String

    init(snap: DataSnapshot) {
        key = snap.key
        
        let value = snap.value as? NSDictionary
        category = value?["category"] as? String ?? ""
        cost = value?["cost"] as? String ?? ""
        hobbyName = value?["hobbyName"] as? String ?? ""
        time = value?["time"] as? String ?? ""
    }
    init() {
        key = ""
        category = ""
        cost = ""
        hobbyName = ""
        time = ""
    }
}
