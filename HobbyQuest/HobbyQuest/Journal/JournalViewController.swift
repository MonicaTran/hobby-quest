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

class JournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EntryViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate {
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statCell", for: indexPath) as! StatisticsCollectionViewCell
        
        cell.layer.cornerRadius = 8.0
        cell.clipsToBounds = true
        cell.statDesc.text = "Journal Entries"
        cell.statValue.text = String(self.journalEntries.count)
        
        return cell
    }
    
    
    
    let fbHelper = FirebaseHelper()
    let journalsRef = Database.database().reference().child("journals")
    var userJournalRef: DatabaseReference!
    var journalEntries = [JournalEntry]()
    var allJournalEntries = [JournalEntry]()
    var hobbyPickerData = [String]()
    var selectedHobby = ""
    let layout = VegaScrollFlowLayout()
    let centeredCollectionViewFlowLayout = CenteredCollectionViewFlowLayout()

    
    @IBOutlet weak var statsCollection: UICollectionView!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let uid = "1"
        //temp uid for testing
        
        statsCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self))
        statsCollection.setCollectionViewLayout(centeredCollectionViewFlowLayout, animated: true)
        statsCollection.showsVerticalScrollIndicator = false
        statsCollection.showsHorizontalScrollIndicator = false
        
        centeredCollectionViewFlowLayout.invalidateLayout()
        centeredCollectionViewFlowLayout.itemSize = CGSize(width: 200, height: 110)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let animation = AnimationType.from(direction: .left, offset: 30.0)
        tableView.animate(animations: [animation])
        centeredCollectionViewFlowLayout.scrollToPage(index: 2, animated: false)
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        print(userID)
        userJournalRef = journalsRef.child(userID)
        fbHelper.getDataAsArray(ref: userJournalRef, typeOf: journalEntries, completion: { array in
            self.journalEntries = array
            print(array)
            self.allJournalEntries = array
            self.tableView.reloadData()
            self.statsCollection.reloadData()
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
    
    
    @IBOutlet weak var addEntryButton: UIButton!
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
    
    @IBOutlet weak var currentFilterChoice: UILabel!
    @IBAction func filterJournalEntries(_ sender: Any) {
        let alertController = UIAlertController(title: "Select Hobby", message: "Select the hobby you would like to filter your journal entries by.", preferredStyle: .actionSheet)
        if hobbyPickerData.count <= 1 {
            alertController.message = "You have no hobbies saved to your journal. Visit the Explore tab to browse and add hobbies."
        }
        else {
            for hobby in hobbyPickerData {
                let okAction = UIAlertAction(title: hobby, style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    let selected = hobby
                    self.journalEntries = self.allJournalEntries
                    if selected != "All Hobbies" {
                        self.journalEntries = self.journalEntries.filter { $0.hobby == selected }
                        self.currentFilterChoice.text = "Filtered by " + hobby
                    } else {
                        self.currentFilterChoice.text = " "
                    }
                    self.tableView.reloadData()
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
    
    let transition = BubbleTransition()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "journalToEntry")
        {
            let dvc = segue.destination as? EntryViewController
            dvc?.transitioningDelegate = self
            dvc?.modalPresentationStyle = .custom
            dvc?.hobby = self.selectedHobby
            dvc?.delegate = self
        }
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = addEntryButton.center
        transition.bubbleColor = addEntryButton.backgroundColor!
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = addEntryButton.center
        transition.bubbleColor = addEntryButton.backgroundColor!
        return transition
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
            let minutes = finalDuration/60
            remainingMinutes = minutes%60
            hours = finalDuration/3600

        }
        
//
//        print(originalDuration!)
//        print(seconds)
//        print(minutes)
//        print(hours)
        
        print(self.fbHelper.getReadableTimestamp(from: String(describing: entry.key)))
        let detailsLabel = cell.viewWithTag(1) as? UILabel
        detailsLabel?.text = "\(entry.hobby) | \(hours) hours and \(remainingMinutes) minutes"
        let descLabel = cell.viewWithTag(2) as? UILabel
        descLabel?.text = entry.description
        let dateLabel = cell.viewWithTag(3) as? UILabel
        dateLabel?.text = self.fbHelper.getReadableTimestamp(from: String(describing: entry.key))
        
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
