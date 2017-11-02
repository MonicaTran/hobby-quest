//
//  DetailsViewController.swift
//  HobbyQuest
//
//  Created by Ubicomp7 on 11/1/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var hobby: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var time: UILabel!

    var hobbyIn = ""
    var categoryIn = ""
    var costIn = ""
    var timeIn = ""

  
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //self.tabBarController?.tabBar.isHidden = true
//        self.navigationController?.popViewController(animated: true)
        self.title = hobbyIn
        hobby.text = ""
        category.text = categoryIn
        cost.text = costIn
        time.text = timeIn
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
