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
    var userMantra = ""
    var image = UIImage()
    var picker = UIImagePickerController()
    var imageURL = ""
    var editToggle = 0
    
    var listOfMantras = ["Anxiety is contagious. And so is calm.",
                         "Expect nothing and appreciate everything.",
                         "Create a life you can be proud of",
                         "Don’t say maybe if you want to say no",
                         "Don’t say maybe if you want to say no",
                         "Everyday is a second chance.",
                         "Die with memories not dreams",
                         "Choose purpose over perfect",
                         "Be someone who makes you happy",
                         "Find a way or make one",
                         "Feel the fear and do it anyway",
                         "Life doesn’t get easier you just get stronger",
                         "Find yourself and be that"]
    
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
        displayNameAlert()
    }
    @IBAction func editEmailButton(_ sender: Any) {
        displayEmailAlert()
    }
    @IBAction func editMantraButton(_ sender: Any) {
        displayMantraAlert()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setGradientBackground()
        
        picker.delegate = self
        //self.view.addSubview(profileImage)
        makeImageCircular(image: profileImage)
        userID = (Auth.auth().currentUser?.uid)!
        
        getUserMantra()
        getProfileImageURL()

        userEmail = (Auth.auth().currentUser?.email)!
        
        emailLabel.text = userEmail
        guard let userDisplayName = Auth.auth().currentUser?.displayName else {
            displayNameAlert()
            return
        }
        welcomeLabel.text = "Hi " + userDisplayName + "!"
        displayLabel.text = userDisplayName
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
    
    func displayEmailAlert(){
        let alert = UIAlertController(title: "Change Email", message: "Enter a new valid email address", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.userEmail
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler :nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                
                Auth.auth().currentUser?.updateEmail(to: textField.text!, completion: { (err) in
                    if err != nil{
                        self.alertForSubmit(message:(err?.localizedDescription)!)
                        print("Unsuccessful change.")
                    }
                    else{
                        self.emailLabel.text = textField.text!
                        print("Email has been updated.")
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
        
    func displayNameAlert(){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Display Name", message: "Enter a display name using at least 5 characters", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
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
                            self.userDisplayName = textField.text!
                            self.displayLabel.text = self.userDisplayName
                            self.welcomeLabel.text = "Hi, \(self.userDisplayName)!"
                            self.addDisplayToDatabase()
                            print("Profile Name has been updated.")
                        }
                    })
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler :nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func displayMantraAlert(){
        let alert = UIAlertController(title: "Change Mantra", message: "Enter a personal mantra or select a random one!", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.mantraLabel.text

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                
                if textField.text != nil{
                    self.userMantra = textField.text!
                    self.updateMantraToDatabase(mantra:self.userMantra)
                    print("Mantra has been updated!")
                }
                else{
                    self.alertForSubmit(message:"Invalid input!")
                    self.displayMantraAlert()
                }

                
            }))
            alert.addAction(UIAlertAction(title: "Random Mantra", style: .default, handler : { [weak alert] (_) in
                let randomIndex = Int(arc4random_uniform(UInt32(self.listOfMantras.count)))
                self.mantraLabel.text = self.listOfMantras[randomIndex]
                self.userMantra = self.mantraLabel.text!
                self.updateMantraToDatabase(mantra:self.userMantra)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler :nil))

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
    

    
    
    func getUserMantra(){
        let mantraRef = Database.database().reference().child("Users")
        let query = mantraRef.queryOrdered(byChild: "UserID").queryEqual(toValue: self.userID)
        query.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                guard let mantraFromDB = child.childSnapshot(forPath: "mantra").value as? String? else{
                    self.userMantra = ""
                    self.mantraLabel.text = self.userMantra
                    return
                }
                print("Printing mantra from DB")
                self.userMantra = mantraFromDB!
                self.mantraLabel.text = self.userMantra
                print(mantraFromDB!)
            }
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
    
    func alertForSubmit(message:String){
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        
    func addDisplayToDatabase(){
        print("Adding Display Name to Database")
        
        let value = ["displayName": self.userDisplayName]
        let newRef = Database.database().reference().child("Users")
        let query = newRef.queryOrdered(byChild: "UserID").queryEqual(toValue: self.userID)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            //let userChoiceID = object4[0] as? String
            let path = uniqueId!
            newRef.child(path).updateChildValues(value)
        }
    }
    func updateMantraToDatabase(mantra:String){
        print("Adding Mantra to Database")
            let value = ["mantra": mantra]
            let newRef = Database.database().reference().child("Users")
            let query = newRef.queryOrdered(byChild: "UserID").queryEqual(toValue: self.userID)
            query.observeSingleEvent(of: .value) { (snapshot) in
                let object = ((snapshot.value as AnyObject).allKeys)!
                let uniqueId = object[0] as? String
                //let userChoiceID = object4[0] as? String
                let path = uniqueId!
                newRef.child(path).updateChildValues(value)
            }

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
