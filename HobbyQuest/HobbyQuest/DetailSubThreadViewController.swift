//
//  DetailSubThreadViewController.swift
//  HobbyQuest
//
//  Created by Huy  Tran  on 11/10/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import Firebase

class DetailSubThreadViewController: UIViewController {
    var retrieve_title = String()
    var status = String()
    let imageCache = NSCache<AnyObject, AnyObject>()
    var imageURL = String()
    var count = Int()
    @IBOutlet weak var retrieveStatus: UILabel!
    
    @IBAction func likeButton(_ sender: Any) {
    }
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func commentButton(_ sender: Any) {
        performSegue(withIdentifier: "detailToComment", sender: self)
    }
    @IBOutlet weak var retreiveImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        retrievePostInfo()
        
        self.commentButton.setTitle("Comment", for: .normal)
        self.likeButton.setTitle("Like", for: .normal)
        
 
       

        // Do any additional setup after loading the view.
    }
    func retrievePostInfo(){
     let ref = Database.database().reference().child("PostInfo")
     let query = ref.queryOrdered(byChild: "post_title").queryEqual(toValue: self.retrieve_title)
        query.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
            self.retrieveStatus.text = (child.childSnapshot(forPath: "status").value as? String)!
            self.imageURL = (child.childSnapshot(forPath: "postImage").value as? String)!
            self.downLoadImageFromFirebase(url: self.imageURL)
          
            }
        }
    }
    func downLoadImageFromFirebase(url:String){
        if url == "" {
        }
        else{
            if let cacheImage = self.imageCache.object(forKey: url as AnyObject){
                self.retreiveImage.image = cacheImage as? UIImage
            }
            let downloadUrl = URL(string:url)
            URLSession.shared.dataTask(with: downloadUrl!, completionHandler: { (data, response, error) in
                if error != nil{
                    return
                }
                DispatchQueue.main.async {
                    self.retreiveImage.image = UIImage(data:data!)
                }
              
            }).resume()
        }
        }
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToComment"{
            let detailTransfer = segue.destination as! CommentViewController
            detailTransfer.post_title = self.retrieve_title
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
