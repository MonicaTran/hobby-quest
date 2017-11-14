//
//  SubThreadTableViewController.swift
//  HobbyQuest
//
//  Created by Huy  Tran  on 11/10/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import Firebase

class SubThreadTableViewController: UITableViewController {
    var post = [String]()
    var subThreadsHobby = String()
    var post_title = String()
    override func viewDidLoad() {
        super.viewDidLoad()
   navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func addTapped(){
    performSegue(withIdentifier: "subThreadToSetup", sender: self)
    }
    func loadSubThreadForEachHobby(){
        var array = [String]()
        let subThreadRef = Database.database().reference().child("Subthread")
        let query = subThreadRef.queryOrdered(byChild: "hobby").queryEqual(toValue: subThreadsHobby)
        query.observe(.value, with: {(snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value: String = (child.childSnapshot(forPath: "post_name").value as? String)!;
                array.append(value)
                
            }
            self.post = array
            array.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subThreadView",for:indexPath)
        cell.textLabel?.text = post[indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.post_title = post[indexPath.item]
        performSegue(withIdentifier: "subThreadToDetail", sender: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        loadSubThreadForEachHobby()

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
        return post.count
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subThreadToSetup"{
            let setupTransfer = segue.destination as! SetupDetailViewController
            setupTransfer.hobbyName = self.subThreadsHobby
        }
        if segue.identifier == "subThreadToDetail"{
            let subThreadTrasfer = segue.destination as! DetailSubThreadViewController
            subThreadTrasfer.retrieve_title = post_title
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
