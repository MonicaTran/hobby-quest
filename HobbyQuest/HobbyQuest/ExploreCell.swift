//
//  ExploreCell.swift
//  HobbyQuest
//
//  Created by Ubicomp7 on 11/1/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit

class ExploreCell: UITableViewCell {
    
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var hobbyLabel: UILabel!
    @IBOutlet weak var catAndTimeLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
