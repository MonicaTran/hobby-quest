//
//  SuggestedPlacesViewController.swift
//  HobbyQuest
//
//  Created by Huy  Tran  on 11/14/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
class SuggestedPlacesViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var search: UIButton!
    
    @IBOutlet weak var mapDisplay: MKMapView!
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            print("Successfully Signed Out")
            self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
        }catch let err{
            print(err.localizedDescription)
            
        }
    }
    
    private let clientID = "Je-rUdnsd2ua-YVW6mBF5g"
    private let clientSecret = "vvYIKgsvUoZiVikgQusHmPFOMwHRBBQcQA0wUwOrdRscllKiqeHkUD0pfGHe8jQB"
  

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
