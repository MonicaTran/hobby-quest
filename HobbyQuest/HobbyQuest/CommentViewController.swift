//
//  CommentViewController.swift
//  HobbyQuest
//
//  Created by Huy  Tran  on 11/13/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: UIViewController {
    @IBOutlet weak var sendMessage: UIButton!
    
    @IBOutlet weak var displayComment: UIView!
    @IBOutlet weak var retrieve_comment: UITextField!
    @IBAction func sendMessage(_ sender: Any) {
        upLoadMessage()
        self.retrieve_comment.text = ""
    }
    var post_title =  String()
    var userComment = String()
    override func viewDidLoad() {
        super.viewDidLoad()
    self.sendMessage.setTitle("Send", for: .normal)
        
        print(self.retrieve_comment.text!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func upLoadMessage(){
        if self.retrieve_comment.text! == ""{
            
        }
        else{
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        let timeStamp = Int(NSDate().timeIntervalSinceNow)
        let ref = Database.database().reference().child("Comment")
        let value = ["userId":userID, "comment": self.retrieve_comment.text!,"post_title":self.post_title,"timeStamp": timeStamp] as [String : Any]
            ref.childByAutoId().updateChildValues(value)
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayComment"{
            let displayComment = segue.destination as! DisplayCommentTableViewController
            displayComment.post = self.post_title
        }
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
