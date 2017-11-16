//
//  ProfileViewController.swift
//  HobbyQuest
//
//  Created by Ubicomp7 on 11/16/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileViewController: UIViewController {

    var ref: DatabaseReference?
    var userID = ""
    var userEmail = ""
    
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userID = (Auth.auth().currentUser?.uid)!
        userEmail = (Auth.auth().currentUser?.email)!
        print (userID, userEmail)
        guard let userDisplayName = Auth.auth().currentUser?.displayName else {
            print("You must set a display name!")
            return
        }
        
        print (userID, userEmail, userDisplayName)
        
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//    func getUserInfo() {
//
//        let ref = Database.database().reference().child("Users")
//        let query = ref.queryOrdered(byChild: "UserID").queryEqual(toValue: self.userID)
//        query.observeSingleEvent(of: .value) { (snapshot) in
//            let object = ((snapshot.value as AnyObject).allKeys)!
//            let uniqueId = object[0] as? String
//            //let userChoiceID = object4[0] as? String
//            let categoryPath = uniqueId!+"/userChoice/category"
//
//
//            let email = (snapshot.childSnapshot(forPath: categoryPath).value! as? String)!
//        }
//    }

}
