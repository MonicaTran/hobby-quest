//
//  DisplayCommentTableViewController.swift
//  HobbyQuest
//
//  Created by Huy  Tran  on 11/13/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import Firebase
class DisplayCommentTableViewController: UITableViewController {
    var userName = [String]()
    var comment = [String]()
    var imageProfile = [String]()
    var post = String()
    let imageCache = NSCache<AnyObject, AnyObject>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func viewDidAppear(_ animated: Bool) {
      retrieveComment()
    
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func retrieveComment(){
        var arrayUserId = [String]()
        var commentFromUser = [String]()
        var arrayImage = [String]()
        var names = [String]()
        let ref = Database.database().reference().child("Comment")
        let query = ref.queryOrdered(byChild: "post_title").queryEqual(toValue: self.post)
        query.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                arrayUserId.append((child.childSnapshot(forPath: "userId").value as? String)!)
                arrayImage.append((child.childSnapshot(forPath: "profileImage").value as?String)!)
                commentFromUser.append((child.childSnapshot(forPath: "comment").value as? String)!)
                names.append((child.childSnapshot(forPath: "userName").value as? String)!)
            }
        self.comment = commentFromUser
        self.imageProfile = arrayImage
        self.userName = names
        commentFromUser.removeAll()
        arrayImage.removeAll()
        names.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "displayComment",for:indexPath)
        let userNameLabel = cell.viewWithTag(3) as! UILabel
        let commentLabel = cell.viewWithTag(1) as! UILabel
        commentLabel.text = self.comment[indexPath.row]
        userNameLabel.text = self.userName[indexPath.row]
        let imageDisplay = cell.viewWithTag(2) as! UIImageView
        let url = self.imageProfile[indexPath.row]
        if url == ""{
            imageDisplay.image = #imageLiteral(resourceName: "profile")
            
        }
        else{
            if let cacheImage = self.imageCache.object(forKey: url as AnyObject){
                imageDisplay.image = cacheImage as? UIImage
            }
        let downloadUrl = URL(string:url)
        URLSession.shared.dataTask(with: downloadUrl!, completionHandler: { (data, response, error) in
            if error != nil{
                return
            }
            DispatchQueue.main.async {
                imageDisplay.image = UIImage(data:data!)
            }
            
        }).resume()
            
        }
        
        
        
        return cell

    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.comment.count
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
