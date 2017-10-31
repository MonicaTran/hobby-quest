//
//  LoginViewController.swift
//  HobbyQuest
//
//  Created by Ubicomp7 on 10/25/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    var ref: DatabaseReference?

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    var email = ""
    var firstTimeArray: [Bool] = []

    @IBAction func action(_ sender: UIButton) {
        
        
        
        if emailText.text! != "" && passwordText.text! != ""{
            
            if segmentControl.selectedSegmentIndex==0{
                //Login selected
                Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, err) in
                    if user != nil{
                        print("Successful Login!")
                        let ref = Database.database().reference().child("Users")
                        let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: self.emailText.text!)
                        query.observeSingleEvent(of: .value) { (snapshot) in
                            let object = ((snapshot.value as AnyObject).allKeys)!
                            let uniqueId = object[0] as? String
                            //let userChoiceID = object4[0] as? String
                            let path = uniqueId!+"/First time"
                            print(snapshot.childSnapshot(forPath: path).value as! Bool)
                            if (snapshot.childSnapshot(forPath: path).value! as? Bool) == true{
                                self.performSegue(withIdentifier: "loginToQuiz", sender: self)
                            }
                            else{
                                self.performSegue(withIdentifier: "loginToExplorer", sender: self)
                            }
                        }
                       
                    }
                    else{
                        if let error = err?.localizedDescription{
                            print(error)
                        }
                        else{
                            print("Unsuccessful Login :(")
                        }
                    }
                })
            }
            else{
                //Sign up selected
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, err) in
                    if user != nil{
                        print("Successfully created a user!")
                        guard let userID = Auth.auth().currentUser?.uid else{return}
                        self.ref = Database.database().reference()
                        self.ref?.child("Users").childByAutoId().setValue(["email" : self.emailText.text!, "UserID" : userID, "First time" : true])
                        
                        //let usersRef = Database.database().reference().child("Users")
                        
                        self.performSegue(withIdentifier: "loginToQuiz", sender: self)
                    }
                    else{
                        if let error = err?.localizedDescription{
                            print(error)
                        }
                        else{
                            print("Unsuccessful Sign up :(")
                        }
                    }
                })
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToQuiz"{
            let qvc = segue.destination as! QuizViewController
            qvc.userEmail = emailText.text!
        }
        else if segue.identifier == "loginToExplorer"{
            let evc = segue.destination as! ExploreViewController
            evc.email = emailText.text!
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

}
