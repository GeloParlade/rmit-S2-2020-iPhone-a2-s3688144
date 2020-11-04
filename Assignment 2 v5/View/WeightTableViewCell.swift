//
//  WeightTableViewCell.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 30/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import UIKit

//Custom table cell for the WeightTable
class WeightTableViewCell: UITableViewCell {

    @IBOutlet weak var Weight: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
