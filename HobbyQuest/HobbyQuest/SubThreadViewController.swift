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
    var userName = [String]()
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
    @objc func handleLike(sender: UIButton){
        let index = sender.tag
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        count = likes[index]
        let ref = Database.database().reference().child("Users")
        let query = ref.queryOrdered(byChild: "UserID").queryEqual(toValue: userID)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!


            let uniqueId = object[0] as? String
            let path = uniqueId! + "/" + self.titlePost[index] + "/" + "flagCheck"
            let pathCheck = uniqueId! + "/" + self.titlePost[index]
            if snapshot.hasChild(pathCheck){

                self.selected = (snapshot.childSnapshot(forPath: path).value as? Bool)!
                if(self.selected == false){
                    self.count+=1
                    self.likes[index] = self.count
                    self.selected = true
                    self.uploadLikeToFirebase(int: index)
                    self.uploadUserFlagCheckToFirebase(int: index)

                }
                else{
                    print("Dislike")
                    self.count-=1
                    self.likes[index] = self.count
                    self.selected = false
                    self.uploadLikeToFirebase(int: index)
                    self.uploadUserFlagCheckToFirebase(int: index)

                }

                print("hahahahahah\(self.selected)")


            }
            else{
                self.selected = false
                //if(self.selected == false){
                    self.count+=1
                    self.likes[index] = self.count
                    self.selected = true
                    self.uploadLikeToFirebase(int: index)
                    self.uploadUserFlagCheckToFirebase(int: index)
//
//                }
//                else{
//                    print("Dislike")
//                    self.count-=1
//                    self.selected = false
//                    self.uploadLikeToFirebase(int: index)
//                    self.uploadUserFlagCheckToFirebase(int: index)
//
//                }

                print("aaa\(self.selected)")
            }
        
            self.collectionView.reloadData()
            
        }
        
        
    }
    @objc func handleComment(){
        performSegue(withIdentifier: "subToComment", sender: self)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"threadInfo" , for: indexPath) as! ThreadInfoCollectionViewCell
        cell.statusLabel.text = post[indexPath.row]
        
        cell.likeButton.setTitle("Likes \(likes[indexPath.row])", for: .normal)
        
        
        
        
        
        cell.commentButton.setTitle("Comment", for: .normal)
        
        cell.likeButton.tag = indexPath.row
        print(indexPath.row)
        
        cell.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        let urlForPostImage = self.postImage[indexPath.row]
        if urlForPostImage == ""{
            
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
    func uploadUserFlagCheckToFirebase(int: Int){
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        let userValue = ["flagCheck":selected,"userId":userID] as [String: Any]
        let ref = Database.database().reference()
        let ref1 = Database.database().reference().child("Users")
        let query = ref1.queryOrdered(byChild: "UserID").queryEqual(toValue: userID)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            let path = "Users/"+uniqueId!+"/"+self.titlePost[int]
            ref.child(path).updateChildValues(userValue)
        }
        
    }
    
    func retrieveFlagCheck(int: Int){
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        
        let ref = Database.database().reference().child("Users")
        let query = ref.queryOrdered(byChild: "UserID").queryEqual(toValue: userID)
        query.observe(.value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            
            
            let uniqueId = object[0] as? String
            let path = uniqueId! + "/" + self.titlePost[int] + "/" + "flagCheck"
            let pathCheck = uniqueId! + "/" + self.titlePost[int]
            if snapshot.hasChild(pathCheck){
                
                DispatchQueue.main.async {
                    self.selected = (snapshot.childSnapshot(forPath: path).value as? Bool)!
                }
                
                
                
            }
            else{
                self.selected = false
                
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
            
        }
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

        var likes = [Int]()
        var titlePost = [String]()
        let subThreadRef = Database.database().reference().child("Subthread")
        let query = subThreadRef.queryOrdered(byChild: "threadForHobby").queryEqual(toValue: subThreadsHobby)
        query.observe(.value, with: {(snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value: String = (child.childSnapshot(forPath: "status").value as? String)!;
                let postImage: String = (child.childSnapshot(forPath: "postImage").value as? String)!

                if child.hasChild("Likes"){
                    self.count = (child.childSnapshot(forPath: "Likes").value as? Int)!
                }
                else{
                    self.count = 0
                }
                
                let title: String =  (child.childSnapshot(forPath: "post_title").value as? String)!
                
                likes.append(self.count)
                array.append(value)
                imagePost.append(postImage)
    
                titlePost.append(title)
                
                
                
            }
            
            self.likes = likes
            self.post = array
            self.postImage = imagePost
   
            self.titlePost = titlePost
            self.collectionView.reloadData()
            
            DispatchQueue.main.async {
            }
            array.removeAll()
            titlePost.removeAll()
            imagePost.removeAll()
   
            likes.removeAll()
            
            
            
        })
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
