//
//  JournalEntry.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/18/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase

class JournalEntry {
    let key:Any
    let description:String
    let duration:String
    let hobby:String
    let rating:String
    
    init(snap: DataSnapshot) {
        key = snap.key
        
        let value = snap.value as? NSDictionary
        description = value?["description"] as? String ?? ""
        duration = value?["duration"] as? String ?? ""
        hobby = value?["hobby"] as? String ?? ""
        rating = value?["rating"] as? String ?? ""
    }
    init(k:Any,de:String,du:String,h:String,r:String) {
        key = k
        description = de
        duration = du
        hobby = h
        rating = r
    }
}
