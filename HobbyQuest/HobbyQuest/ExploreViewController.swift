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
    var answers = ["med","sports","hours"]
    let fbHelper = FirebaseHelper()
    let hobbiesRef = Database.database().reference().child("hobbies")
    var hobbies = [Hobby]()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.answers)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        fbHelper.getDataAsArray(ref: hobbiesRef, typeOf: hobbies, completion: { array in
            self.hobbies = array
        
            
            //filtering array for 3 categories. cost, category, time:
            var hobbyWithAll = self.hobbies.filter{$0.cost == self.answers[0] && $0.category == self.answers[1] && $0.time == self.answers[2]}
            //filtering array for 2 categories: cost, category:
            let hobbyWithCostAndCat = self.hobbies.filter{$0.cost == self.answers[0] && $0.category == self.answers[1]}
            //filtering array for 2 categories: category, time:
            let hobbyWithCatAndTime = self.hobbies.filter{$0.category == self.answers[1] && $0.time == self.answers[2]}
            
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
            print(self.removeDuplicates(array: hobbyName))
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
        return hobbies.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hobbyCell", for: indexPath)
        let hobby = hobbies[indexPath.row]
        cell.textLabel?.text = hobby.hobbyName
        let catAndTime = "\(hobby.category) | Time: \(hobby.time) | Cost: \(hobby.cost)"
        cell.detailTextLabel?.text = catAndTime
        // Configure the cell...
        
        return cell
    }


    

}
