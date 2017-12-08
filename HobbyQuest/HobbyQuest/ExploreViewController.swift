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

extension String{
    func capitalizeFirstLetter()-> String{
        return prefix(1).uppercased() + dropFirst()
    }
    mutating func capitalizeFirstLetter(){
        self = self.capitalizeFirstLetter()
    }
}



class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    var savedHobbies = [String:String]() //used to update buttons based on previously saved hobbies.
    var selectedHobby = Hobby()
    var answers = [String]()
    var email:String = ""
    let fbHelper = FirebaseHelper()
    let hobbiesRef = Database.database().reference().child("hobbies")
    var hobbies = [Hobby]()
    var category:String = ""
    var cost:String = ""
    var time:String = ""
    var dupFreeHobbies = [String]()
    var finalHobbies = [Hobby]()
    var images = [UIImage?]()
    var tempImage:UIImage?
    
    func addAlert(message:String){
        let alert = UIAlertController(title: "Hobby Added!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteAlert(message:String){
        let alert = UIAlertController(title: "Hobby deleted!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func addHobby(sender: UIButton) {
        let button = sender
        let index = sender.tag
        if (button.imageView?.image == #imageLiteral(resourceName: "add1")) {
            addAlert(message: "\(finalHobbies[index].hobbyName.capitalizeFirstLetter()) has been added to your hobby list.")
            guard let userID = Auth.auth().currentUser?.uid else{return}
            let ref = Database.database().reference().child("savedHobbies")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(userID) {
                    let timeStamp = self.fbHelper.getTimestamp()
                    let key = String(timeStamp)
                    let hobby = self.dupFreeHobbies[index]
                    let entry = [key:hobby]
                    
                    ref.child(userID).observeSingleEvent(of: .value) { (snapshot) in
                        var hobbyExists = false
                        for child in snapshot.children {
                            let item = child as! DataSnapshot
                            let value = item.value as! String
                            if value == hobby {
                                hobbyExists = true
                            }
                        }
                        if !hobbyExists {
                            ref.child(userID).updateChildValues(entry)
                            
                        }
                    }
                }
                else {
                    let timeStamp = self.fbHelper.getTimestamp()
                    let key = String(timeStamp)
                    let hobby = self.dupFreeHobbies[index]
                    let entry = [key:hobby]
                    ref.child(userID).setValue(entry)
                }
            }
            button.setImage(UIImage(named: "delete1"), for: UIControlState.normal)
        }
        else {
            
            deleteAlert(message: "\(finalHobbies[index].hobbyName.capitalizeFirstLetter()) has been deleted from your class.")
            guard let userID = Auth.auth().currentUser?.uid else{return}
            let ref = Database.database().reference().child("savedHobbies")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(userID) {
                    let hobby = self.finalHobbies[index].hobbyName
                    var dictionary = [String:String]()
                    var hobbyKey:String?
                    ref.child(userID).observeSingleEvent(of: .value) { (snapshot) in
                        var hobbyExists = false
                        for child in snapshot.children {
                            
                            let item = child as! DataSnapshot
                            let value = item.value as! String
                            dictionary[item.key] = value
                            if value == hobby {
                                hobbyKey = item.key
                                hobbyExists = true
                            }
                        }
                        if hobbyExists {
                            ref.child(userID).child(hobbyKey!).removeValue()
                        }
                    }
                }
                
            }
            
            button.setImage(UIImage(named: "add1"), for: UIControlState.normal)
        }
        
        //TODO: Add delete function here when button is switched to delete1 image
        //Make delete button appear at start if the hobby has already been added.
        
        
        
        //        button.backgroundColor = UIColor(red: 0/255, green: 153/255, blue: 51/255, alpha: 1)
        //        button.setTitleColor(UIColor.white, for: .normal)
        //        button.setTitle("REMOVE", for: .normal)
        
        
        
    }
    func removeDuplicates(array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                
            }
            else {
                encountered.insert(value)
                result.append(value)
            }
        }
        return result
        
    }
    func retrieveUserAnswers() {
        
        let ref = Database.database().reference().child("Users")
        let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: self.email)
        query.observeSingleEvent(of: .value) { (snapshot) in
            let object = ((snapshot.value as AnyObject).allKeys)!
            let uniqueId = object[0] as? String
            //let userChoiceID = object4[0] as? String
            let categoryPath = uniqueId!+"/userChoice/category"
            let costPath = uniqueId!+"/userChoice/cost"
            let timePath = uniqueId!+"/userChoice/time"
            //no hobbies given currently. FIX PLS
            self.category = (snapshot.childSnapshot(forPath: categoryPath).value! as? String)!
            self.cost = (snapshot.childSnapshot(forPath: costPath).value! as? String)!
            self.time = (snapshot.childSnapshot(forPath: timePath).value! as? String)!
            
            self.answers.append(self.category)
            self.answers.append(self.cost)
            self.answers.append(self.time)
            
        }
        
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.retrieveUserAnswers()
        fillSavedHobbies()
        
        
        fbHelper.getDataAsArray(ref: hobbiesRef, typeOf: hobbies, completion: { array in
            self.hobbies = array
            
            //filtering array for 3 categories. cost, category, time:
            let hobbyWithAll = self.hobbies.filter{$0.cost == self.cost && $0.category == self.category && $0.time == self.time}
            //filtering array for 2 categories: cost, category:
            let hobbyWithCostAndCat = self.hobbies.filter{$0.cost == self.cost && $0.category == self.category}
            //filtering array for 2 categories: category, time:
            let hobbyWithCatAndTime = self.hobbies.filter{$0.category == self.category && $0.time == self.time}
            let hobbyWithCat = self.hobbies.filter{$0.category == self.category}
            
            var newHobbies = [Hobby]()
            for item in hobbyWithAll {
                newHobbies.append(item)
            }
            for item in hobbyWithCostAndCat {
                newHobbies.append(item)
            }
            for item in hobbyWithCatAndTime {
                newHobbies.append(item)
            }
            for item in hobbyWithCat {
                newHobbies.append(item)
            }
            var hobbyName = [String]()
            let num = newHobbies.count
            for i in 0 ..< num {
                hobbyName.append(newHobbies[i].hobbyName)
            }
            
            self.dupFreeHobbies = self.removeDuplicates(array: hobbyName)
            //creates a sorted duplicate-free array from dupFreeHobbies' names.
            var i = 0
            for item in self.dupFreeHobbies {
                var flag = true
                i = 0;
                while flag {
                    
                    if newHobbies[i].hobbyName == item {
                        self.finalHobbies.append(newHobbies[i])
                        flag = false
                    }
                    i+=1
                }
            }

            DispatchQueue.main.async { self.tableView.reloadData()
                
            }
        })
        //fills up savedHobbies dictionary.
        //Okay I'm stuck here. Because it is asynchronous, the code doesn't work the way I expected it to. It should fill up the savedHobbies dictionary, then update the table to have buttons depending on which ones alraedy have been saved.
        
        
    }
    
    
    
    func fillSavedHobbies(){
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let ref = Database.database().reference().child("savedHobbies")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(userID) {
                print("Filling up saved hobbies")
                ref.child(userID).observeSingleEvent(of: .value) { (snapshot) in
                    
                    for child in snapshot.children {
                        let item = child as! DataSnapshot
                        let value = item.value as! String
                        self.savedHobbies[item.key] = value
                    }
                    
                }
            }

            self.collectionView.reloadData()
            _ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.dispatchingQueue), userInfo: nil, repeats: false)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func dispatchingQueue(){
        DispatchQueue.main.async { self.tableView.reloadData()
            self.collectionView.reloadData()
        }
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hobbies.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hobbyCell", for: indexPath) as! ExploreCell
        let hobby = hobbies[indexPath.row]
        cell.hobbyLabel.text = hobby.hobbyName.capitalizeFirstLetter()
        let catAndTime = "\(hobby.category) | Time: \(hobby.time) | Cost: \(hobby.cost)"
        cell.catAndTimeLabel.text = catAndTime
        
        
        //cell.button.layer.cornerRadius = 5
        //cell.button.layer.borderWidth = 1
        //cell.button.layer.borderColor = UIColor(red: 0/255, green: 153/255, blue: 51/255, alpha: 1).cgColor
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(self.addHobby), for: UIControlEvents.touchUpInside)
        
        for item in savedHobbies {
            print("Hobby: " + item.value)
            if hobby.hobbyName == item.value {
                print("Adding delete button")
                cell.button.setImage(UIImage(named: "delete1"), for: UIControlState.normal)
                
            }
        }
        
        
        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedHobby = hobbies[indexPath.row]
        performSegue(withIdentifier: "exploreToDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exploreToDetail"{
            let dvc = segue.destination as! DetailsViewController
            dvc.hobbyIn = selectedHobby.hobbyName
            dvc.costIn = selectedHobby.cost
            dvc.categoryIn = selectedHobby.category
            dvc.descriptionIn = selectedHobby.description
            dvc.timeIn = selectedHobby.time
            dvc.url = selectedHobby.postImage
            dvc.wikiLink = selectedHobby.wikiHowLink
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            print("Successfully Signed Out")
            self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
        }catch let err{
            print(err.localizedDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return finalHobbies.count
    }
    
    //Populating views
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! HobbyCollectionViewCell

        cell.hobbyImageView.layer.cornerRadius = 8.0
        cell.hobbyImageView.clipsToBounds = true
        let downloadUrl = URL(string:finalHobbies[indexPath.row].postImage)
        URLSession.shared.dataTask(with: downloadUrl!, completionHandler: { (data, response, error) in
            if error != nil{
                return
            }
            DispatchQueue.main.async {
                cell.hobbyImageView.image = UIImage(data:data!)
            }
        }).resume()
        cell.hobbyNameLabel.text = finalHobbies[indexPath.row].hobbyName
        cell.hobbyCategoryLabel.text = finalHobbies[indexPath.row].category.capitalizeFirstLetter()
        cell.hobbyCostLabel.text = convertCostToDollarSigns(cost:finalHobbies[indexPath.row].cost)
        return cell
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! HobbyCollectionViewCell
//        cell.hobbyImageView.image = tempImage[indexPath.row]
//        return cell
    }
    
    
    func convertCostToDollarSigns(cost:String) -> String{
        if cost == "low"{
            return "$"
        }
        else if cost == "med"{
            return "$$"
        }
        else if cost == "high"{
            return "$$$"
        }
        else{
            return ""
        }
    }
    
    
}

