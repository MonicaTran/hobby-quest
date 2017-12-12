//
//  CommunityTableViewController.swift
//  HobbyQuest
//
//  Created by Huy  Tran  on 11/10/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class CommunityTableViewController: UITableViewController {
    let fbHelper = FirebaseHelper()
    var hobbies = [Hobby]()
    var hobbyTranser = String()
    @IBAction func logout(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            print("Successfully Signed Out")
            self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
        }catch let err{
            print(err.localizedDescription)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if Auth.auth().currentUser?.displayName == nil{
            print("NO USERNAME")
            displayNameAlert()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        fbHelper.getAllHobbies { (array) in
            self.hobbies = array
            DispatchQueue.main.async {
                self.tableView.reloadData()}
        }
     
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "communityHobbies",for:indexPath)
        cell.textLabel?.text = hobbies[indexPath.item].hobbyName
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.hobbyTranser = hobbies[indexPath.item].hobbyName
        performSegue(withIdentifier: "communityToSub", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "communityToSub"{
            let subThread = segue.destination as!  SubThreadViewController
            subThread.subThreadsHobby = self.hobbyTranser
        }
        
        
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

         Configure the cell...

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
    func displayNameAlert(){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Display Name", message: "Enter a display name using at least 5 characters", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                
                guard let textFieldSize = textField.text?.count else {self.displayNameAlert()
                    return}
                if textFieldSize < 5{
                    self.displayNameAlert()
                }
                else{
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = textField.text
                    changeRequest?.commitChanges(completion: { (err) in
                        if err != nil{
                            print("Unsuccessful change.")
                        }
                        else{
                            self.addDisplayToDatabase()
                            print("Profile Name has been updated.")
                        }
                    })
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func addDisplayToDatabase(){
        print("Adding Display Name to Database")
        
        let value = ["displayName": Auth.auth().currentUser?.displayName]
        let newRef = Database.database().reference().child("Users")
        let query = newRef.queryOrdered(byChild: "UserID").queryEqual(toValue: Auth.auth().currentUser?.uid)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            //let userChoiceID = object4[0] as? String
            let path = uniqueId!
            newRef.child(path).updateChildValues(value)
        }
    }
}
