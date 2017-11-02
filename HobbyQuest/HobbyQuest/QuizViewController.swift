//
//  ViewController.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/12/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import Firebase
import UIKit
struct storedUserchoice{
    var user_choice_Cost:String
    var user_choice_Category:String
    var user_choice_Time:String
    var user_answer_set = [String]()
    init(){
        user_choice_Cost = ""
        user_choice_Category = ""
        user_choice_Time = ""
    }
}

class QuizViewController: UIViewController {
    var totalQuestion = 0 ;
    var user = storedUserchoice()
    var userEmail = ""
    var retakeQuiz = false
    

    
    
    @IBOutlet weak var questionNumber: UILabel!
    
    @IBAction func previousQuestion(_ sender: Any) {
        self.nextDisabled.isHidden = false
        totalQuestion -= 1
        populatedLabel()
        setupPreviousButton()
    }
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBAction func input1(_ sender: Any) {

       
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
        setupNextQuestionButton()
    }
    func alertForSubmit(){
        let alert = UIAlertController(title: "Error", message: "You haven't answered all of the questions", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //display result
    @IBAction func submitAnswer(_ sender: Any) {
        getInput(input1: user.user_choice_Cost, input2: user.user_choice_Category, input3: user.user_choice_Time)
        if(user.user_answer_set.count < 3){
            self.alertForSubmit()
            title_button3.isSelected = false
            title_button2.isSelected = false
            title_button1.isSelected = false
        }
            else{
            uploadData()
            performSegue(withIdentifier: "quizToExplore", sender: self)
        }
 
    }

    func setupPreviousButton(){
   
        if totalQuestion == 0{
            self.previousButton.isHidden = true
        }
    }
    func setupNextQuestionButton(){
        title_button3.isSelected = false
        title_button2.isSelected = false
        title_button1.isSelected = false

  
        if totalQuestion == 2{
            self.nextDisabled.isHidden = true
            self.submitDisabled.isHidden = false
        }
    }


    func populatedLabel(){
            switch(totalQuestion){
            case 0:
                self.questionNumber.text = "1/3"
                self.question.text = "Cost?"
                self.title_button1.setTitle("high", for: .normal)
                self.title_button2.setTitle("med", for: .normal)
                self.title_button3.setTitle("low", for: .normal)
                break
            case 1:
                self.questionNumber.text = "2/3"
                self.question.text = "Category?"
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
    func getInput(input1:String,input2:String,input3:String){
        if(user.user_answer_set.count < 3){
            user.user_answer_set.removeAll()
            if(input1 != ""){user.user_answer_set.append(input1)}
            if(input2 != ""){user.user_answer_set.append(input2)}
            if(input3 != ""){user.user_answer_set.append(input3)}
            print(user.user_answer_set.count)
        }
        
    }

    func uploadData(){
        let userChoice = [
            "cost": user.user_answer_set[0],
            "category": user.user_answer_set[1],
            "time": user.user_answer_set[2]
        ]
        let ref = Database.database().reference()
        let ref1 = Database.database().reference().child("Users")
        let query = ref1.queryOrdered(byChild: "email").queryEqual(toValue: self.userEmail)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            let path = "Users/"+uniqueId!+"/userChoice"
            ref.child(path).setValue(userChoice)       }
    }
    //update userChoice in case user want to take the quiz again
    func updateData(){
        let userChoice = [
            "cost": user.user_answer_set[0],
            "category": user.user_answer_set[1],
            "time": user.user_answer_set[2]
        ]
        let ref = Database.database().reference()
        let ref1 = Database.database().reference().child("Users")
        let query = ref1.queryOrdered(byChild: "email").queryEqual(toValue: self.userEmail)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            let path = "Users/"+uniqueId!+"/userChoice"
            ref.child(path).updateChildValues(userChoice)     }
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        populatedLabel()

        
        self.previousButton.isHidden = true
        self.submitDisabled.isHidden = true

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

