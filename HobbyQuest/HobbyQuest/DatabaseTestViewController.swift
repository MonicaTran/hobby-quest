//
//  DatabaseTestViewController.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/12/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct Hobby {
    let key:Any
    let category:String
    let cost:String
    let hobbyName:String
    let time:String
    
    init(snap: DataSnapshot) {
        key = snap.key
        
        let value = snap.value as? NSDictionary
        category = value?["category"] as? String ?? ""
        cost = value?["cost"] as? String ?? ""
        hobbyName = value?["hobbyName"] as? String ?? ""
        time = value?["time"] as? String ?? ""
    }
}

class DatabaseTestViewController: UITableViewController {
    
    var ref: DatabaseReference!
    var hobbies = [Hobby]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        ref = Database.database().reference()
        getHobbyData()
        tableView.reloadData()
        
        ref.child("hobbies").observe(.value) { snapshot in
            self.hobbies = [Hobby]()
            for child in snapshot.children {
                self.addHobby(child: child as! DataSnapshot)
            }
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Firebase functions
     */
    
    func getHobbyData() {
        ref.child("hobbies").observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                self.addHobby(child: child as! DataSnapshot)
            }
        }
    }
    
    func addHobby(child: DataSnapshot) {
        let hobby = Hobby(snap: child)
        self.hobbies.append(hobby)
    }
    
    /*
     // MARK: - Table view functions
     */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hobbies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let hobby = hobbies[indexPath.row]
        
        // Configure Cell
        cell.textLabel?.text = hobby.hobbyName
        
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
