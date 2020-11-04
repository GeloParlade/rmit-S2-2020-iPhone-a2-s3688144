//
//  MealTableViewCell.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 23/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//
import UIKit

//Custom table cell for the MealsTable
class MealTableViewCell: UITableViewCell {

    
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var mealTime: UILabel!
    @IBOutlet weak var mealCal: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
