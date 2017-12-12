//
//  SubThreadViewController.swift
//  HobbyQuest
//
//  Created by Huy  Tran  on 12/10/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import Firebase

class SubThreadViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var post = [String]()
   
    var postImage = [String]()
    var userNames = [String]()
    var postStatus = [String]()
    var subThreadsHobby = String()
    var post_title = String()
    var titlePost = [String]()
    var likes = [Int]()
    
    let imageCacheForPost = NSCache<AnyObject, AnyObject>()

    var count = Int()
    var selected = Bool()
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.count
    }
   
    override func viewDidAppear(_ animated: Bool) {
       loadSubThreadForEachHobby()
        super.viewDidAppear(true)
    }
    @objc func handleComment(){
        performSegue(withIdentifier: "subToComment", sender: self)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"threadInfo" , for: indexPath) as! ThreadInfoCollectionViewCell
        cell.statusLabel.text = post[indexPath.row]
        
   
        
        
        
        
        cell.userName.text = userNames[indexPath.row]
        cell.commentButton.setTitle("Comment", for: .normal)
        
       
        
        
        
        cell.commentButton.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        let urlForPostImage = self.postImage[indexPath.row]
        if urlForPostImage == ""{
            let defaultURL = URL(string:"https://firebasestorage.googleapis.com/v0/b/hobbyquest-ee18d.appspot.com/o/newspaper.png?alt=media&token=cf9645e6-2c06-44ab-86e5-1906fc87b5b2")
            URLSession.shared.dataTask(with: defaultURL!, completionHandler: { (data, response, error) in
                if error != nil{
                    return
                }
                DispatchQueue.main.async {
                    cell.postImage.image = UIImage(data:data!)
                }
                
            }).resume()
            
        }
        else{
            if let cacheImage = self.imageCacheForPost.object(forKey: urlForPostImage as AnyObject){
                cell.postImage.image = cacheImage as? UIImage
            }
            let downloadUrl = URL(string:urlForPostImage)
            URLSession.shared.dataTask(with: downloadUrl!, completionHandler: { (data, response, error) in
                if error != nil{
                    return
                }
                DispatchQueue.main.async {
                    cell.postImage.image = UIImage(data:data!)
                }
                
            }).resume()
            
        }

        
        
        return cell
    }

    
 
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        return CGSize(width: view.frame.width, height: 150)
    //    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        loadSubThreadForEachHobby()
     
        
    }
    
    func uploadLikeToFirebase(int: Int){
        let i = int
        let value = ["Likes":count] as [String : Any]
        
        let ref = Database.database().reference()
        let ref1 = Database.database().reference().child("Subthread")
        
        let query = ref1.queryOrdered(byChild: "post_title").queryEqual(toValue: self.titlePost[i])
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            let path = "Subthread/"+uniqueId!
            ref.child(path).updateChildValues(value)
        }
        
    }
    

    func loadSubThreadForEachHobby(){
        var array = [String]()
        //        var arrayProfileImage = [String]()
        var imagePost = [String]()
        var names = [String]()
    
        var titlePost = [String]()
        let subThreadRef = Database.database().reference().child("Subthread")
        let query = subThreadRef.queryOrdered(byChild: "threadForHobby").queryEqual(toValue: subThreadsHobby)
        query.observeSingleEvent(of: .value) { (snapshot) in
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value: String = (child.childSnapshot(forPath: "status").value as? String)!;
                let postImage: String = (child.childSnapshot(forPath: "postImage").value as? String)!
                let name : String = (child.childSnapshot(forPath: "userName").value as? String)!
                
                
                let title: String =  (child.childSnapshot(forPath: "post_title").value as? String)!
                
                
                array.append(value)
                imagePost.append(postImage)
                names.append(name)
                titlePost.append(title)
                
                
                
            }
            
            
            self.post = array
            self.postImage = imagePost
            self.userNames = names
            self.titlePost = titlePost
            self.collectionView.reloadData()
            
            DispatchQueue.main.async {
            }
            array.removeAll()
            titlePost.removeAll()
            imagePost.removeAll()
            names.removeAll()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       post_title = titlePost[indexPath.row]
      performSegue(withIdentifier: "subToComment", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func addTapped(){
        performSegue(withIdentifier: "subToSetup", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subToSetup"{
            let setupTransfer = segue.destination as! SetupDetailViewController
            setupTransfer.hobbyName = self.subThreadsHobby
        }
        if segue.identifier == "subToComment"{
            let setupTransfer = segue.destination as! CommentViewController
            setupTransfer.post_title = self.post_title
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
