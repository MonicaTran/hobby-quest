//
//  LoginViewController.swift
//  HobbyQuest
//
//  Created by Ubicomp7 on 10/25/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {


    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    
    @IBAction func action(_ sender: UIButton) {
        if emailText.text != "" && passwordText.text == ""{
            if segmentControl.selectedSegmentIndex==0{
                //Login selected
                Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, err) in
                    if user != nil{
                        print("Successful Login!")
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
