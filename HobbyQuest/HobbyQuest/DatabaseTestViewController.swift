//
//  DatabaseTestViewController.swift
//  HobbyQuest
//
//  Created by Monica Tran on 10/12/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DatabaseTestViewController: UITableViewController {
    
    let fbHelper = FirebaseHelper()
    let hobbiesRef = Database.database().reference().child("hobbies")
    var hobbies = [Hobby]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fbHelper.getDataAsArray(ref: hobbiesRef, typeOf: hobbies, completion: { array in
            self.hobbies = array
            self.tableView.reloadData()
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
