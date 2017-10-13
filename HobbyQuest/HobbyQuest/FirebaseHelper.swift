//
//  FirebaseHelper.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/13/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FirebaseHelper: NSObject {
    
    func getDataAsArray<T> (ref: DatabaseReference, typeOf: [T], completion: @escaping ([T]) -> Void) {
        var array = [T]()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if typeOf is [Hobby] {
                print("Hobby")
                for child in snapshot.children {
                    array.append(Hobby(snap: child as! DataSnapshot) as! T)
                }
            }
            completion(array)
        }
    }
    
}
