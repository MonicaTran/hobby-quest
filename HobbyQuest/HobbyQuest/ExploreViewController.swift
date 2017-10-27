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

    var answers = [String]()
    let fbHelper = FirebaseHelper()
    let hobbiesRef = Database.database().reference().child("hobbies")
    var hobbies = [Hobby]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.answers)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        fbHelper.getDataAsArray(ref: hobbiesRef, typeOf: hobbies, completion: { array in
            self.hobbies = array
            //filtering array for 3 categories. cost, category, time:
            var hobbyThree = self.hobbies.filter{$0.cost == self.answers[0] && $0.category == self.answers[1] && $0.time == self.answers[2]}
            //filtering array for 2 categories: cost, category:
            let hobbyTwo = self.hobbies.filter{$0.cost == self.answers[0] && $0.category == self.answers[1]}
            //filtering array for 2 categories: category, time:
            let secondHobbyTwo = self.hobbies.filter{$0.category == self.answers[1] && $0.time == self.answers[2]}

            for item in hobbyTwo
            {
                hobbyThree.append(item)
            }
            for item in secondHobbyTwo
            {
                hobbyThree.append(item)
            }
            //Set(hobbyThree) //gives a segmentation fault. I'll just keep duplicates for now.
            self.hobbies = hobbyThree
            self.tableView.reloadData()
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
