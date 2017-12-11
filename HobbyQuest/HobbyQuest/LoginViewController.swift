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


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var ref: DatabaseReference?
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    var email = ""
    var firstTimeArray: [Bool] = []
    @IBOutlet var authButton: PMSuperButton!
    var isLoading = false
    
    @IBAction func authStateChanged(_ sender: Any) {
//        switch segmentControl.selectedSegmentIndex
//        {
//            case 0:
//                authButton.setTitle("Login", for: .normal)
//            case 1:
//                authButton.setTitle("Register", for: .normal)
//            default:
//                break;
//        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //textField code
        
        //passwordText.resignFirstResponder()  //if desired
        self.action()

        return true
    }
    
//    func performAction() {
//        print("Enter key has been pressed")
//    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func action(_ sender: AnyObject? = nil) {
        
        if emailText.text! != "" && passwordText.text! != ""{
            if segmentControl.selectedSegmentIndex==0{
                //Login selected
                attemptLogin()
            }
            else{
                //Sign up selected
                createUser()
            }
        }
    }
    
    func createUser(){
        Auth.auth().createUser(withEmail: emailText.text!.lowercased(), password: passwordText.text!, completion: { (user, err) in
            if user != nil{
                self.addUserToDatabase()
                self.performSegue(withIdentifier: "loginToQuiz", sender: self)
            }
            else{
                if let error = err?.localizedDescription{
                    self.alertForSubmit(message: error)
                    print(error)
                }
                else{
                    print("Unsuccessful Sign up :(")
                    self.isLoading = false
                    self.authButton.hideLoader()
                    self.authButton.setTitleColor(.white, for: .normal)
                }
            }
        })
    }
    
    func addUserToDatabase(){
        print("Successfully created a user!")
        guard let userID = Auth.auth().currentUser?.uid else{return}
        self.ref = Database.database().reference()
        self.ref?.child("Users").childByAutoId().setValue(["email" : self.emailText.text!, "UserID" : userID, "First time" : true])
    }
    
    func attemptLogin(){
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, err) in
            if user != nil{
                print("Successful Login!")
                let lowerEmail = self.emailText.text?.lowercased()
                let ref = Database.database().reference().child("Users")
                let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: lowerEmail)
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
                        self.performSegue(withIdentifier: "loginToExplore", sender: self)
                    }
                }
            }
            else{
                if let error = err?.localizedDescription{
                    print(error)
                    if error == "There is no user record corresponding to this identifier. The user may have been deleted."{
                        self.alertForSubmit(message: "Username or password is incorrect.")
                    }else{self.alertForSubmit(message: error)}
                }
                else{print("Unsuccessful Login :(")}
                self.isLoading = false
                self.authButton.hideLoader()
                self.authButton.setTitleColor(.white, for: .normal)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToQuiz"{
            let qvc = segue.destination as! QuizViewController
            qvc.userEmail = emailText.text!
        }
        else if segue.identifier == "loginToExplore"{
            let tbc: UITabBarController = segue.destination as! UITabBarController
            let evc: ExploreViewController = tbc.viewControllers?.first?.childViewControllers.first as! ExploreViewController
            evc.email = emailText.text!
        }
        emailText.text = ""
        passwordText.text = ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordText.delegate = self
        
        self.setGradientBackground()
//        let layer = CAGradientLayer()
//        layer.frame = self.view.frame
//        layer.locations = [0.0,0.35]
//        layer.colors = [UIColor.green.cgColor, UIColor.white.cgColor]
//        view.layer.insertSublayer(layer, at: 0)

        
        // Do any additional setup after loading the view.
        
        authButton.touchUpInside {
            self.isLoading = true
            self.authButton.showLoader()
            self.authButton.setTitleColor(.clear, for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.isLoading = true
        self.authButton.hideLoader()
        self.authButton.setTitleColor(.white, for: .normal)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertForSubmit(message:String){
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
