//
//  ViewController.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/12/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import Firebase
import UIKit
import FirebaseAuth
struct storedUserchoice{
    var user_choice_Cost:String
    var user_choice_Category:String
    var user_choice_Time:String
    init(){
        user_choice_Cost =  ""
        user_choice_Category = ""
        user_choice_Time = ""
    }

}

class QuizViewController: UIViewController {
    var totalQuestion = 0 ;
    var userEmail = ""
    var retakeQuiz = false
    var user = storedUserchoice()
    var green = UIColor(red: 90.0/255.0, green: 171.0/255.0, blue: 141.0/255.0, alpha: 1)
    

    
    
    @IBAction func logout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            print("Successfully Signed Out")
        }catch let err{
            print(err.localizedDescription)
        }
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var questionNumber: UILabel!
    
    @IBAction func previousQuestion(_ sender: Any) {
        self.nextDisabled.isHidden = false
        totalQuestion -= 1
        populatedLabel()
        title_button1.setTitleColor(green, for: .normal)
        title_button2.setTitleColor(green, for: .normal)
        title_button3.setTitleColor(green, for: .normal)
        setupPreviousButton()
    }
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBAction func input1(_ sender: Any) {
        

        title_button2.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button2.setTitleColor(green, for: .normal)
        title_button3.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button3.setTitleColor(green, for: .normal)
        title_button1.backgroundColor = UIColor(red: 90.0/255.0, green: 171.0/255.0, blue: 141.0/255.0, alpha: 1)
        title_button1.setTitleColor(UIColor.white, for: .normal)
        
        if title_button1.titleLabel?.text! == "high" {
            title_button2.isSelected = false
            title_button3.isSelected = false
             title_button1.isSelected = true
            
            user.user_choice_Cost = "high"
        }
        else if title_button1.titleLabel?.text! == "sports"{
            title_button2.isSelected = false
            title_button3.isSelected = false
            title_button1.isSelected = true
            user.user_choice_Category = "sports"
        }
        else if title_button1.titleLabel?.text! == "days"{
            title_button2.isSelected = false
            title_button3.isSelected = false
            title_button1.isSelected = true
            user.user_choice_Time = "days"
        }
    }
    
    @IBAction func input2(_ sender: Any) {
        
        title_button2.backgroundColor = UIColor(red: 90.0/255.0, green: 171.0/255.0, blue: 141.0/255.0, alpha: 1)
        title_button2.setTitleColor(UIColor.white, for: .normal)
        title_button1.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button1.setTitleColor(green, for: .normal)
        title_button3.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button3.setTitleColor(green, for: .normal)

        if title_button2.titleLabel?.text! == "med" {
            title_button3.isSelected = false
            title_button1.isSelected = false
            title_button2.isSelected = true
            
            user.user_choice_Cost = "med"
        }
        else if title_button2.titleLabel?.text! == "art"{
            title_button3.isSelected = false
            title_button1.isSelected = false
            title_button2.isSelected = true
            user.user_choice_Category = "art"
        }
        else if title_button2.titleLabel?.text! == "hours"{
            title_button3.isSelected = false
            title_button1.isSelected = false
            title_button2.isSelected = true
            user.user_choice_Time = "hours"
        }
    }
    
    @IBAction func input3(_ sender: Any) {
        
        title_button3.backgroundColor = UIColor(red: 90.0/255.0, green: 171.0/255.0, blue: 141.0/255.0, alpha: 1)
        title_button3.setTitleColor(UIColor.white, for: .normal)
        title_button1.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button1.setTitleColor(green, for: .normal)
        title_button2.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button2.setTitleColor(green, for: .normal)

        if title_button3.titleLabel?.text! == "low" {
            title_button2.isSelected = false
            title_button1.isSelected = false
            title_button3.isSelected = true
            user.user_choice_Cost = "low"
        }
        else if title_button3.titleLabel?.text! == "collecting"{
            title_button2.isSelected = false
            title_button1.isSelected = false
            title_button3.isSelected = true
            user.user_choice_Category = "collecting"
        }
        else if title_button3.titleLabel?.text! == "minutes"{
            title_button2.isSelected = false
            title_button1.isSelected = false
            title_button3.isSelected = true
            user.user_choice_Time = "minutes"
        }
    }
    @IBOutlet weak var nextDisabled: UIButton!
    @IBOutlet weak var submitDisabled: UIButton!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var title_button1: UIButton!
    @IBOutlet weak var title_button2: UIButton!
    @IBOutlet weak var title_button3: UIButton!
    @IBAction func nextQuestion(_ sender: Any) {
        self.previousButton.isHidden = false
        totalQuestion += 1
        populatedLabel()
        title_button1.setTitleColor(green, for: .normal)
        title_button2.setTitleColor(green, for: .normal)
        title_button3.setTitleColor(green, for: .normal)
        setupNextQuestionButton()
    }
    func alertForSubmit(){
        let alert = UIAlertController(title: "Error", message: "You haven't answered all of the questions", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitAnswer(_ sender: Any) {
        if(user.user_choice_Cost == "" || user.user_choice_Category == "" || user.user_choice_Time == ""){
            self.alertForSubmit()
            title_button3.isSelected = false
            title_button2.isSelected = false
            title_button1.isSelected = false
        }
            
            else{
            updateData()
            performSegue(withIdentifier: "quizToExplore", sender: self)
        }
        if(user.user_choice_Cost == ""){
            totalQuestion = 0
            populatedLabel()
        }
        if(user.user_choice_Category == ""){
            totalQuestion = 1
            populatedLabel()
        }
        if(user.user_choice_Time == ""){
            totalQuestion = 2
            populatedLabel()
        }

 
    }

    func setupPreviousButton(){
        title_button1.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button2.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button3.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        if totalQuestion == 0{
            self.previousButton.isHidden = true
        }
    }
    func setupNextQuestionButton(){
        title_button3.isSelected = false
        title_button2.isSelected = false
        title_button1.isSelected = false
        
        title_button1.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button2.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button3.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)

  
        if totalQuestion == 2{
            self.nextDisabled.isHidden = true
            self.submitDisabled.isHidden = false
        }
    }


    func populatedLabel(){
            switch(totalQuestion){
            case 0:
                self.questionNumber.text = "1."
                self.question.text = "What is your budget for hobbies?"
                self.title_button1.setTitle("high", for: .normal)
                self.title_button2.setTitle("med", for: .normal)
                self.title_button3.setTitle("low", for: .normal)
                break
            case 1:
                self.questionNumber.text = "2."
                self.question.text = "What "
                self.title_button1.setTitle("sports", for: .normal)
                self.title_button2.setTitle("art", for: .normal)
                self.title_button3.setTitle("collecting", for: .normal)
                break
            case 2:
                self.questionNumber.text = "3/3"
                self.question.text = "Time?"
                self.title_button1.setTitle("days", for: .normal)
                self.title_button2.setTitle("hours", for: .normal)
                self.title_button3.setTitle("minutes", for: .normal)
                break
            default:
                break}

        }

    func updateData(){
        let userChoice = [
            "cost": user.user_choice_Cost,
            "category": user.user_choice_Category,
            "time": user.user_choice_Time
        ]
        let ref = Database.database().reference()
        let ref1 = Database.database().reference().child("Users")
        let query = ref1.queryOrdered(byChild: "email").queryEqual(toValue: self.userEmail)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            let path = "Users/"+uniqueId!+"/userChoice"
            ref.child(path).updateChildValues(userChoice)
            ref.child("Users/"+uniqueId!+"/First time").setValue(false)
        }
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        populatedLabel()
        
        self.setGradientBackground()

        
        self.previousButton.isHidden = true
        self.submitDisabled.isHidden = true
        
        
        title_button1.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button2.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        title_button3.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)

    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabVC = segue.destination as! UITabBarController
        let navVC = tabVC.viewControllers?.first as! UINavigationController
        let evc = navVC.viewControllers.first as! ExploreViewController

        evc.email = userEmail
  }


}

