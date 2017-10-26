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
    var user_choice_Recommendation = [String]()
    var key_value:String = ""
    
    
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
            user.user_choice_Cost = "high"
        }
        else if title_button1.titleLabel?.text! == "sports"{
            user.user_choice_Category = "sports"
        }
        else if title_button1.titleLabel?.text! == "days"{
            user.user_choice_Time = "days"
        }
    }
    
    @IBAction func input2(_ sender: Any) {
        if title_button2.titleLabel?.text! == "med" {
            user.user_choice_Cost = "med"
        }
        else if title_button2.titleLabel?.text! == "art"{
            user.user_choice_Category = "art"
        }
        else if title_button2.titleLabel?.text! == "hours"{
            user.user_choice_Time = "hours"
        }
    }
    
    @IBAction func input3(_ sender: Any) {
        if title_button3.titleLabel?.text! == "low" {
            user.user_choice_Cost = "low"
        }
        else if title_button3.titleLabel?.text! == "collecting"{
            user.user_choice_Category = "collecting"
        }
        else if title_button3.titleLabel?.text! == "minutes"{
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
        if(user.user_answer_set.count < 3){
            self.alertForSubmit()
        }
            else{
            //getKeyvalue()
            //getData()
        }
 
    }

    func setupPreviousButton(){
        if totalQuestion == 0{
            self.previousButton.isHidden = true
        }
    }
    func setupNextQuestionButton(){
        if totalQuestion == 2{
            self.nextDisabled.isHidden = true
            self.submitDisabled.isHidden = false
        }
    }

    func getInput(input1:String,input2:String,input3:String){
        if(user.user_answer_set.count <= 3){
        user.user_answer_set.removeAll()
        if(input1 != ""){user.user_answer_set.append(input1)}
        if(input2 != ""){user.user_answer_set.append(input2)}
        if(input3 != ""){user.user_answer_set.append(input3)}}
        
        
       
    }
//    func getKeyvalue(){
//         key_value = user.user_answer_set[0] + "_" + user.user_answer_set[1] + "_" + user.user_answer_set[2]
//    }
//
////Firebase doesn't support multiple queries
//    func getData(){
//        let ref = Database.database().reference().child("hobbies")
//        let query = ref.queryOrdered(byChild: "cost_category_time").queryEqual(toValue: key_value)
//        query.observe(.value, with: {(snapshot1) in
//            for child in snapshot1.children.allObjects as! [DataSnapshot] {
//                let value: String = (child.childSnapshot(forPath: "hobbyName").value as? String)!;
//                self.user_choice_Recommendation.append(value)}
//            print(self.user_choice_Recommendation)
//
//        })
//    }

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
        //had to move code from submitAnswer.
        getInput(input1: user.user_choice_Cost, input2: user.user_choice_Category, input3: user.user_choice_Time)
        let dvc = segue.destination as! ExploreViewController
        dvc.answers = user.user_answer_set
    }

}

