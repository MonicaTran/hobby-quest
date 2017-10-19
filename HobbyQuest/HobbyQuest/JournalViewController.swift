//
//  JournalViewController.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/18/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase

class JournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EntryViewControllerDelegate {
    
    
    let fbHelper = FirebaseHelper()
    let journalsRef = Database.database().reference().child("journals")
    var userJournalRef: DatabaseReference!
    var journalEntries = [JournalEntry]()
    var selectedHobby = ""
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalEntriesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = "1"
        //temp uid for testing
        userJournalRef = journalsRef.child(uid)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fbHelper.getDataAsArray(ref: userJournalRef, typeOf: journalEntries, completion: { array in
            self.journalEntries = array
            self.tableView.reloadData()
        })
        totalEntriesLabel.text = String(journalEntries.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - New entry functions
     */
    
    @IBAction func addEntry(_ sender: Any) {
        fbHelper.getAllHobbies(completion: { array in
            self.showAlertSelectHobby(from:array)
        })
    }
    
    func showAlertSelectHobby(from: [Hobby]) {
        let alertController = UIAlertController(title: "Select Hobby", message: "Select the hobby you would like to write about.", preferredStyle: .actionSheet)
        
        for hobby in from {
            let okAction = UIAlertAction(title: hobby.hobbyName, style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.selectedHobby = hobby.hobbyName
                self.performSegue(withIdentifier: "journalToEntry", sender: self)
            }
            alertController.addAction(okAction)
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
    
/*
 // MARK: - Table view
 */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journalEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let entry = journalEntries[indexPath.row]
        cell.textLabel?.text = entry.description
        
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
