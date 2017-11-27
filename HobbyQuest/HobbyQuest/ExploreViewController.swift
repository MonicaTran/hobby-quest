//
//  ExploreViewControllerTableViewController.swift
//  HobbyQuest
//
//  Created by Ubicomp7 on 10/25/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//
import FirebaseDatabase
import FirebaseAuth
import UIKit

extension String{
    func capitalizeFirstLetter()-> String{
        return prefix(1).uppercased() + dropFirst()
    }
    mutating func capitalizeFirstLetter(){
        self = self.capitalizeFirstLetter()
    }
}



class ExploreViewController: UITableViewController{
    
    
    var selectedHobby = ""
    var answers = [String]()
    var email:String = ""
    let fbHelper = FirebaseHelper()
    let hobbiesRef = Database.database().reference().child("hobbies")
    var hobbies = [Hobby]()
    var category:String = ""
    var cost:String = ""
    var time:String = ""
    var dupFreeHobbies = [String]()
    var finalHobbies = [Hobby]()
    
    func addAlert(message:String){
        let alert = UIAlertController(title: "Hobby Added!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    @objc func addHobby(sender: UIButton) {
        let button = sender
        button.isHidden = true
        
        
//        button.backgroundColor = UIColor(red: 0/255, green: 153/255, blue: 51/255, alpha: 1)
//        button.setTitleColor(UIColor.white, for: .normal)
//        button.setTitle("REMOVE", for: .normal)
        
        let index = sender.tag
        addAlert(message: "\(finalHobbies[index].hobbyName.capitalizeFirstLetter()) has been added to your hobby list.")
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let ref = Database.database().reference().child("savedHobbies")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(userID) {
                let timeStamp = self.fbHelper.getTimestamp()
                let key = String(timeStamp)
                let hobby = self.dupFreeHobbies[index]
                let entry = [key:hobby]
                
                ref.child(userID).observeSingleEvent(of: .value) { (snapshot) in
                    var hobbyExists = false
                    for child in snapshot.children {
                        let item = child as! DataSnapshot
                        let value = item.value as! String
                        if value == hobby {
                            hobbyExists = true
                        }
                    }
                    if !hobbyExists {
                        ref.child(userID).updateChildValues(entry)
                    }
                }
            }
            else {
                let timeStamp = self.fbHelper.getTimestamp()
                let key = String(timeStamp)
                let hobby = self.dupFreeHobbies[index]
                let entry = [key:hobby]
                ref.child(userID).setValue(entry)
            }
        }
        
    }
    func removeDuplicates(array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                
            }
            else {
                encountered.insert(value)
                result.append(value)
            }
        }
        return result
        
    }
    func retrieveUserAnswers() {
        
        let ref = Database.database().reference().child("Users")
        let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: self.email)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            //let userChoiceID = object4[0] as? String
            let categoryPath = uniqueId!+"/userChoice/category"
            let costPath = uniqueId!+"/userChoice/cost"
            let timePath = uniqueId!+"/userChoice/time"

            self.category = (snapshot.childSnapshot(forPath: categoryPath).value! as? String)!
            self.cost = (snapshot.childSnapshot(forPath: costPath).value! as? String)!
            self.time = (snapshot.childSnapshot(forPath: timePath).value! as? String)!
            
            self.answers.append(self.category)
            self.answers.append(self.cost)
            self.answers.append(self.time)
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.retrieveUserAnswers()
        
        
        fbHelper.getDataAsArray(ref: hobbiesRef, typeOf: hobbies, completion: { array in
            self.hobbies = array
            
            //filtering array for 3 categories. cost, category, time:
            let hobbyWithAll = self.hobbies.filter{$0.cost == self.cost && $0.category == self.category && $0.time == self.time}
            //filtering array for 2 categories: cost, category:
            let hobbyWithCostAndCat = self.hobbies.filter{$0.cost == self.cost && $0.category == self.category}
            //filtering array for 2 categories: category, time:
            let hobbyWithCatAndTime = self.hobbies.filter{$0.category == self.category && $0.time == self.time}
            
            var newHobbies = [Hobby]()
            for item in hobbyWithAll {
                newHobbies.append(item)
            }
            for item in hobbyWithCostAndCat {
                newHobbies.append(item)
            }
            for item in hobbyWithCatAndTime {
                newHobbies.append(item)
            }
            var hobbyName = [String]()
            let num = newHobbies.count
            for i in 0 ..< num {
                hobbyName.append(newHobbies[i].hobbyName)
            }
            
            self.dupFreeHobbies = self.removeDuplicates(array: hobbyName)
            //creates a sorted duplicate-free array from dupFreeHobbies' names.
            var i = 0
            for item in self.dupFreeHobbies {
                var flag = true
                i = 0;
                while flag {
                
                    if newHobbies[i].hobbyName == item {
                        self.finalHobbies.append(newHobbies[i])
                        flag = false
                    }
                    i+=1
                }
            }
            
            DispatchQueue.main.async { self.tableView.reloadData() }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalHobbies.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hobbyCell", for: indexPath) as! ExploreCell
        let hobby = finalHobbies[indexPath.row]
        cell.hobbyLabel.text = hobby.hobbyName.capitalizeFirstLetter()
        let catAndTime = "\(hobby.category) | Time: \(hobby.time) | Cost: \(hobby.cost)"
        cell.catAndTimeLabel.text = catAndTime

        
        //cell.button.layer.cornerRadius = 5
        //cell.button.layer.borderWidth = 1
        //cell.button.layer.borderColor = UIColor(red: 0/255, green: 153/255, blue: 51/255, alpha: 1).cgColor
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(self.addHobby), for: UIControlEvents.touchUpInside)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedHobby = dupFreeHobbies[indexPath.row]
        performSegue(withIdentifier: "exploreToDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            finalHobbies.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exploreToDetail"{
            let dvc = segue.destination as! DetailsViewController
            dvc.hobbyIn = selectedHobby
            for item in hobbies
            {
                if selectedHobby == item.hobbyName
                {
                    dvc.costIn = item.cost
                    dvc.categoryIn = item.category
                    dvc.timeIn = item.time
                }
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            print("Successfully Signed Out")
            self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
        }catch let err{
            print(err.localizedDescription)
        }
    }
    
    
    
    
}

