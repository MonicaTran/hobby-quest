//
//  ChangePassViewController.swift
//  HobbyQuest
//
//  Created by Ubicomp7 on 12/6/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangePassViewController: UIViewController {
    
    
    @IBOutlet weak var oldPassLabel: UITextField!
    @IBOutlet weak var newPassLabel: UITextField!
    @IBOutlet weak var confirmPassLabel: UITextField!
    
    var oldPass=""
    var newPass=""
    var userEmail=""
    var changeSuccessful = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        


        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func changePassButton(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        self.newPass = newPassLabel.text!
        userEmail = (Auth.auth().currentUser?.email)!
        if oldPassLabel.text != ""{
            oldPass = oldPassLabel.text!
            let credential = EmailAuthProvider.credential(withEmail: userEmail, password: oldPass)
            user?.reauthenticate(with: credential, completion: { (err) in
                if err != nil{
                    self.alertForSubmit(message: "Incorrect Old Password")
                }
                else if self.newPassLabel.text! == self.confirmPassLabel.text!{
                    user?.updatePassword(to: self.newPass, completion: { (err) in
                        if let error2 = err{
                            self.alertForSubmit(message: error2.localizedDescription)
                        }
                        else{
                            self.alertForSuccess(message: "Password has been changed!")
                        }
                    })
                }
                else{
                    self.alertForSubmit(message: "New passwords don't match")
                    
                }
                
            })
        }
        
        
        
    }
    
    func alertForSubmit(message:String){
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertForSuccess(message:String){
        let alert = UIAlertController(title: "Success!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}


