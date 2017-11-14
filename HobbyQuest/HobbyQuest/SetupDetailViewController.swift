//
//  SetupDetailViewController.swift
//  HobbyQuest
//
//  Created by Huy  Tran  on 11/10/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import Firebase

class SetupDetailViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var picker = UIImagePickerController()
    var image = UIImage()
    var useImage = false
    @IBOutlet weak var textVIew: UITextView!
    
    @IBOutlet weak var label_title: UILabel!

    @IBOutlet weak var setupImage: UIImageView!
    

    @IBOutlet weak var label_caption: UILabel!
    @IBOutlet weak var finishSetupOutlet: UIButton!
    
    @IBAction func finishSetup(_ sender: Any) {
        if textVIew.text == ""{
            alertForSubmit()
        }
        else{
        uploadImageToFirebase()
        createPostThreadFirebase()
        performSegue(withIdentifier: "setupToDetail", sender: self)}
    }
    var hobbyName = String()
    @IBOutlet weak var post_name: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        label_title.text = "Title"
        label_caption.text = "Status"
        post_name.placeholder = "Enter title of your post"
        finishSetupOutlet.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 153/255, alpha: 1)
        post_name.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 153/255, alpha: 1)
        textVIew.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 153/255, alpha: 1)
        finishSetupOutlet.setTitle("Finish", for:.normal)
       self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gallery"), style: .done, target: self, action: #selector(openGallery))
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func openGallery(){
        self.picker.allowsEditing = true
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
        var selectedImage:UIImage?
        self.useImage = true
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImage = editedImage
            self.setupImage.image = selectedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImage = originalImage
            self.setupImage.image = selectedImage
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    func alertForSubmit(){
        let alert = UIAlertController(title: "Invalid Input", message: "Please enter a post title", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadImageToFirebase(){
    guard let userID = Auth.auth().currentUser?.uid else{
            return
    }
        if self.useImage == false {
            let value = ["postImage": "","status":self.textVIew.text!,"threadForHobby":self.hobbyName,"post_title": self.post_name.text!,"userID":userID]
            self.registerPostToUser(value: value)
            
        }
        else{
        let uniqueImageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("\(uniqueImageName).png")
            if let uploadData = UIImagePNGRepresentation((setupImage.image)!){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                if let postImage = metadata?.downloadURL()?.absoluteString{
                    let value = ["postImage": postImage,"status": self.textVIew.text!,"threadForHobby": self.hobbyName,"post_title": self.post_name.text!,"userID":userID]
                    self.registerPostToUser(value: value)
                        }
                    }
                )
            }
            
        }
    }

    func createPostThreadFirebase(){
        let subThreadRef = Database.database().reference()
        let value = ["post_name": post_name.text!,"hobby":self.hobbyName]
        let path = "Subthread"
        subThreadRef.child(path).childByAutoId().updateChildValues(value)
    }
    
    private func registerPostToUser(value:[String:Any]){
        let ref = Database.database().reference().child("PostInfo")
        ref.childByAutoId().updateChildValues(value)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupToDetail"{
            let setupTransfer = segue.destination as! DetailSubThreadViewController
            setupTransfer.retrieve_title = self.post_name.text!
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
