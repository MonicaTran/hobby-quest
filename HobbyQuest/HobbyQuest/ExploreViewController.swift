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

class ExploreViewController
: UITableViewController {
    //TODO: Retrieve answers from firebase.
//    var answers = [String]
    var email = ""
    let fbHelper = FirebaseHelper()
    let hobbiesRef = Database.database().reference().child("hobbies")
    var hobbies = [Hobby]()
    var category:String = ""
    var cost:String = ""
    var time:String = ""
    var dupFreeHobbies = [String]()
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
    func retrieveUserData()
    {
//        let ref = Database.database().reference().child("Users")
//        let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: self.email)
//        query.observeSingleEvent(of: .value) { (snapshot) in
//            let object = ((snapshot.value as AnyObject).allKeys)!
//            let uniqueId = object[0] as? String
//            //let userChoiceID = object4[0] as? String
//            let path = uniqueId!+"/userChoice"
//            let userChoiceIDs = ((snapshot.childSnapshot(forPath: path).value as AnyObject).allKeys)!
//            let firstUserChoiceID = userChoiceIDs[0] as? String
//            let categoryPath = path+"/"+firstUserChoiceID!+"/category"
//            let costPath = path+"/"+firstUserChoiceID!+"/cost"
//            let timePath = path+"/"+firstUserChoiceID!+"/time"
//            print(snapshot.childSnapshot(forPath: categoryPath).value!)
//            print(snapshot.childSnapshot(forPath: costPath).value!)
//            print(snapshot.childSnapshot(forPath: timePath).value!)
//            self.category = (snapshot.childSnapshot(forPath: categoryPath).value! as? String)!
//            print(self.category)
//            self.cost = (snapshot.childSnapshot(forPath: costPath).value! as? String)!
//            self.time = (snapshot.childSnapshot(forPath: timePath).value! as? String)!
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    override func viewDidAppear(_ animated: Bool) {
        //retrieveUserData()
        let ref = Database.database().reference().child("Users")
        let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: self.email)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            //let userChoiceID = object4[0] as? String
            let path = uniqueId!+"/userChoice"
            let userChoiceIDs = ((snapshot.childSnapshot(forPath: path).value as AnyObject).allKeys)!
            let firstUserChoiceID = userChoiceIDs[0] as? String
            let categoryPath = path+"/"+firstUserChoiceID!+"/category"
            let costPath = path+"/"+firstUserChoiceID!+"/cost"
            let timePath = path+"/"+firstUserChoiceID!+"/time"
            print(snapshot.childSnapshot(forPath: categoryPath).value!)
            print(snapshot.childSnapshot(forPath: costPath).value!)
            print(snapshot.childSnapshot(forPath: timePath).value!)
            self.category = (snapshot.childSnapshot(forPath: categoryPath).value! as? String)!
            print(self.category)
            self.cost = (snapshot.childSnapshot(forPath: costPath).value! as? String)!
            self.time = (snapshot.childSnapshot(forPath: timePath).value! as? String)!
        }
        
        
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
            print(hobbyName)
            self.dupFreeHobbies = self.removeDuplicates(array: hobbyName)
            //TODO make table print cells based on removeDuplicates array.
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dupFreeHobbies.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hobbyCell", for: indexPath)
        let hobby = dupFreeHobbies[indexPath.row]
        print(hobby)
        cell.textLabel?.text = hobby
        for item in hobbies
        {
            if dupFreeHobbies[indexPath.row] == item.hobbyName
            {
                let catAndTime = "\(item.category) | Time: \(item.time) | Cost: \(item.cost)"
                cell.detailTextLabel?.text = catAndTime
            }
        }
        
        return cell
    }


    

}
