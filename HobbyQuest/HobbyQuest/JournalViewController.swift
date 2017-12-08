//
//  JournalViewController.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/18/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class JournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EntryViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hobbyPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hobbyPickerData[row] as String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = hobbyPickerData[row]
        journalEntries = allJournalEntries
        if selected != "All Hobbies" {
            journalEntries = journalEntries.filter { $0.hobby == selected }
        }
        tableView.reloadData()
    }
    
    
    
    let fbHelper = FirebaseHelper()
    let journalsRef = Database.database().reference().child("journals")
    var userJournalRef: DatabaseReference!
    var journalEntries = [JournalEntry]()
    var allJournalEntries = [JournalEntry]()
    var hobbyPickerData = [String]()
    var selectedHobby = ""
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalEntriesLabel: UILabel!
    @IBOutlet var hobbyFilterPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let uid = "1"
        //temp uid for testing
        hobbyFilterPicker.delegate = self
        hobbyFilterPicker.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        totalEntriesLabel.text = String(journalEntries.count)
        guard let userID = Auth.auth().currentUser?.uid else{
            hobbyFilterPicker.isHidden = true
            return
        }
        userJournalRef = journalsRef.child(userID)
        fbHelper.getDataAsArray(ref: userJournalRef, typeOf: journalEntries, completion: { array in
            self.journalEntries = array
            self.allJournalEntries = array
            self.totalEntriesLabel.text = String(self.journalEntries.count)
            self.tableView.reloadData()
            self.getAvailableHobbies(arr: self.journalEntries)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            print("Successfully Signed Out")
            self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
        }catch let err{
            print(err.localizedDescription)
            
        }
    }
    
    
    @IBAction func addEntry(_ sender: Any) {
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        let savedHobbiesRef = Database.database().reference().child("savedHobbies").child(userID)
        savedHobbiesRef.observeSingleEvent(of: .value) { (snapshot) in
            var userHobbies = [String]()
            for child in snapshot.children {
                let item = child as! DataSnapshot
                let value = item.value as! String
                userHobbies.append(value)
            }
            self.showAlertSelectHobby(from: userHobbies)
            //self.fbHelper.getAllHobbies(completion: { array in
            //    self.showAlertSelectHobby(from:array)
            //})
        }
    }
    
    func showAlertSelectHobby(from: [String]) {
        let alertController = UIAlertController(title: "Select Hobby", message: "Select the hobby you would like to write about.", preferredStyle: .actionSheet)
        if from.count <= 0 {
            alertController.message = "You have no hobbies saved to your journal. Visit the Explore tab to browse and add hobbies."
        }
        else {
            for hobby in from {
                let okAction = UIAlertAction(title: hobby, style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.selectedHobby = hobby
                    self.performSegue(withIdentifier: "journalToEntry", sender: self)
                }
                alertController.addAction(okAction)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancelled")
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "journalToEntry")
        {
            let dvc = segue.destination as? EntryViewController
            dvc?.hobby = self.selectedHobby
            dvc?.delegate = self
        }
    }
    
    func saveNewEntry(desc: String, hobby: String, duration: String) {
        let entry = ["description":desc,"duration":duration,"hobby":hobby]
        let timeStamp = fbHelper.getTimestamp()
        let key = String(timeStamp)
        userJournalRef.child(key).setValue(entry)
        
        let newEntry = JournalEntry(k:timeStamp,de:desc,du:duration,h:hobby)
        journalEntries.append(newEntry)
    }
    
    let ALL_HOBBIES = ["All Hobbies"]
    func getAvailableHobbies(arr: [JournalEntry]) {
        var result = ALL_HOBBIES
        var temp = arr.map { $0.hobby }
        temp = Array(Set(temp))
        result.append(contentsOf: temp)
        hobbyPickerData = result
        hobbyFilterPicker.reloadAllComponents()
    }
    
/*
 // MARK: - Table view
 */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journalEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let entry = journalEntries[indexPath.row]
        //cell.textLabel?.text = entry.hobby + " : " + entry.description + " : " + entry.duration
        //cell.textLabel?.numberOfLines = 0
        //cell.textLabel?.lineBreakMode = .byWordWrapping
        print("duration: \(entry.duration)")
        var hours = 0
        var remainingMinutes = 0
        
        if let originalDuration = Double(entry.duration)
        {
            let finalDuration = Int(originalDuration)
            print("converted to int")
            let minutes = finalDuration/60
            remainingMinutes = minutes%60
            hours = finalDuration/3600
            print(hours)
            print(remainingMinutes)

        }
        
//
//        print(originalDuration!)
//        print(seconds)
//        print(minutes)
//        print(hours)

        let detailsLabel = cell.viewWithTag(1) as? UILabel
        detailsLabel?.text = "\(entry.hobby) | \(hours) hours and \(remainingMinutes) minutes"
        let descLabel = cell.viewWithTag(2) as? UILabel
        descLabel?.text = entry.description
        
        return cell
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
