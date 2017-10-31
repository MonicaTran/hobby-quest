//
//  FirebaseHelper.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/13/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase

//extension String {
//    func makeFirebaseString()->String{
//        let arrCharacterToReplace = [".","#","$","[","]"]
//        var finalString = self
//        
//        for character in arrCharacterToReplace{
//            finalString = finalString.replacingOccurrences(of: character, with: " ")
//        }
//        
//        return finalString
//    }
//}

class FirebaseHelper: NSObject {

    func getDataAsArray<T> (ref: DatabaseReference, typeOf: [T], completion: @escaping ([T]) -> Void) {
        var array = [T]()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if type(of:array) == [Hobby].self {
                for child in snapshot.children {
                    array.append(Hobby(snap: child as! DataSnapshot) as! T)
                }
            }
            else if type(of:array) == [JournalEntry].self {
                for child in snapshot.children {
                    array.append(JournalEntry(snap: child as! DataSnapshot) as! T)
                }
            }
            completion(array)
        }
    }
    
    func getAllHobbies(completion: @escaping ([Hobby]) -> Void) {
        let hobbiesRef = Database.database().reference().child("hobbies")
        getDataAsArray(ref: hobbiesRef, typeOf: [Hobby](), completion: { array in
            completion(array)
        })
    }
    
    func getTimestamp() -> Int {
        let ts = Int(floor(NSDate.timeIntervalSinceReferenceDate*1000))
        return ts
    }
    
}
