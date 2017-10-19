//
//  EntryViewController.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/19/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit

protocol EntryViewControllerDelegate {
    func saveNewEntry(desc:String,hobby:String,duration:String)
}

class EntryViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: EntryViewControllerDelegate!

    var hobby = ""
    var desc = ""
    
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var inputTextField: UITextField!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var durationField: UIDatePicker!
    
    @IBAction func submitDuration(_ sender: Any) {
        performSegue(withIdentifier: "entryToJournal", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.isHidden = true
        durationLabel.isHidden = true
        durationField.isHidden = true
        self.view.viewWithTag(1)?.isHidden = true
        
        greetingLabel.text = "Hi there! How is " + hobby + " going?"
        
        inputTextField.delegate = self
        self.inputTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "entryToJournal") {
            let d = String(self.durationField.countDownDuration)
            self.delegate.saveNewEntry(desc: self.desc, hobby: self.hobby, duration: d)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        desc = textField.text!
        textField.resignFirstResponder()
        descriptionLabel.isHidden = false
        descriptionLabel.text = desc
        textField.isHidden = true
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.durationLabel.isHidden = false
            self.durationLabel.text = "Sounds fun! How long did you spend on " + self.hobby + "?"
        }
        DispatchQueue.main.asyncAfter(deadline: when+1) {
            self.durationField.isHidden = false
            self.view.viewWithTag(1)?.isHidden = false
        }
        
        return true
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
