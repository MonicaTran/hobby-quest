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
    
    @IBOutlet weak var cameraIconButton: UIButton!
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mantraLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var displayNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var mantraView: UIView!
    
    @IBOutlet weak var editButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var displayButtonOutlet: UIButton!
    @IBOutlet weak var emailButtonOutlet: UIButton!
    @IBOutlet weak var mantraButtonOutlet: UIButton!
    
    
    var ref: DatabaseReference?
    var userID = ""
    var userEmail = ""
    var userDisplayName = ""
    var image = UIImage()
    var picker = UIImagePickerController()
    var imageURL = ""
    var editToggle = 0
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        do{
            try Auth.auth().signOut()
            print("Successfully Signed Out")
            self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
        }catch let err{
            print(err.localizedDescription)
            
        }
    }
    @IBOutlet weak var profileImage: UIImageView!
    @IBAction func editButton(_ sender: Any) {
        if editToggle==0{
            editToggle = 1
            displayButtonOutlet.isHidden = false
            emailButtonOutlet.isHidden = false
            mantraButtonOutlet.isHidden = false
            editButtonOutlet.title = "Done"
        }
        else{
            editToggle=0
            displayButtonOutlet.isHidden = true
            emailButtonOutlet.isHidden = true
            mantraButtonOutlet.isHidden = true
            editButtonOutlet.title = "Edit"
        }
    }
    
    @IBAction func editDisplayButton(_ sender: UIButton) {
    }
    @IBAction func editEmailButton(_ sender: Any) {
    }
    @IBAction func editMantraButton(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        picker.delegate = self
        //self.view.addSubview(profileImage)
        makeImageCircular(image: profileImage)
        userID = (Auth.auth().currentUser?.uid)!
        getProfileImageURL()

        userEmail = (Auth.auth().currentUser?.email)!
        
        if Auth.auth().currentUser?.displayName == nil{
            displayNameAlert()
        }
        let userDisplayName = Auth.auth().currentUser?.displayName

        displayLabel.text = userDisplayName
        emailLabel.text = userEmail
        welcomeLabel.text = "Hi " + userDisplayName! + "!"
    }
    
    @IBAction func selectPictureButton(_ sender: Any) {
        self.selectPicture()
    }
    

    
    func makeImageCircular(image: UIImageView){
        image.layer.borderWidth = 3
        image.layer.borderColor = UIColor(rgb: 0xDCEEDE).cgColor
        image.layer.masksToBounds = false
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
    }
    
    func displayNameAlert(){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Display Name", message: "Create a new display name using at least 5 characters", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "Enter Display Name"
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                
                guard let textFieldSize = textField.text?.count else {self.displayNameAlert()
                    return}
                if textFieldSize < 5{
                    self.displayNameAlert()
                }
                else{
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = textField.text
                    changeRequest?.commitChanges(completion: { (err) in
                        if err != nil{
                            print("Unsuccessful change.")
                        }
                        else{
                            self.displayLabel.text = self.userDisplayName
                            print("Profile Name has been updated.")
                        }
                    })
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getProfileImageURL(){
        let ref = Database.database().reference().child("Users")
        let query = ref.queryOrdered(byChild: "UserID").queryEqual(toValue: self.userID)
        query.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                guard let imgURL = child.childSnapshot(forPath: "postImage").value as? String? else{return}
                self.imageURL = imgURL!
                print(self.imageURL)
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
        let alert = UIAlertController(title: "Change Profile Image", message: "Select source", preferredStyle: .actionSheet)
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
    @IBAction func toChangePassword(_ sender: Any) {
        performSegue(withIdentifier: "profileToChange", sender: self)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
