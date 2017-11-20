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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    var ref: DatabaseReference?
    var userID = ""
    var userEmail = ""
    var image = UIImage()
    var picker = UIImagePickerController()
    var imageURL = ""
    
    @IBOutlet weak var profileImage: UIImageView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        userID = (Auth.auth().currentUser?.uid)!
        getProfileImageURL()

        
        picker.delegate = self
        profileImage.isUserInteractionEnabled = true
        let oneTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapping(recognizer:)))
        oneTap.numberOfTapsRequired = 1;
        profileImage.addGestureRecognizer(oneTap)
        
        self.view.addSubview(profileImage)
        
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
    
    func getProfileImageURL(){
        print ("Something")
        let ref = Database.database().reference().child("Users")
        let query = ref.queryOrdered(byChild: "UserID").queryEqual(toValue: self.userID)
        query.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                self.imageURL = (child.childSnapshot(forPath: "postImage").value as? String)!
                print(self.imageURL)
                print("something")
                self.downLoadImageFromFirebase(url: self.imageURL)}
        }
    }
    
    func downLoadImageFromFirebase(url:String){
        if url == "" {
        }
        else{
            let downloadUrl = URL(string:url)
            URLSession.shared.dataTask(with: downloadUrl!, completionHandler: { (data, response, error) in
                if error != nil{
                    return
                }
                DispatchQueue.main.async {
                    self.profileImage.image = UIImage(data:data!)
                }
                
            }).resume()
        }
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
    

    func uploadImage(){
        let uniqueImageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("\(uniqueImageName).jpg")
        if let uploadData = UIImagePNGRepresentation((profileImage.image)!){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                if let postImage = metadata?.downloadURL()?.absoluteString{
                    let value = ["postImage": postImage]
                    let ref = Database.database().reference().child("Users")
                    let query = ref.queryOrdered(byChild: "UserID").queryEqual(toValue: self.userID)
                    query.observeSingleEvent(of: .value) { (snapshot) in
                        
                        let object = ((snapshot.value as AnyObject).allKeys)!
                        let uniqueId = object[0] as? String
                        //let userChoiceID = object4[0] as? String
                        let path = uniqueId!
                        ref.child(path).updateChildValues(value)
                    }
                }
            }
            )
        }
    }
    
    @objc func selectPicture() {
        let alert = UIAlertController(title: "Action", message: "Select source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {_ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.picker.sourceType = .photoLibrary
                self.present(self.picker, animated: true, completion: nil)
            }
        }) )
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {_ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            }
        }) )
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {_ in
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.image = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        profileImage.image = image
        uploadImage()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func singleTapping(recognizer: UIGestureRecognizer) {
        print("image clicked")
        self.selectPicture()
    }

}
