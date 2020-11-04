//
//  SearchTableViewCell.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 23/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import UIKit

protocol MealCellDelegate {
    func didTapMeal(title: String)
}

//Custom table cell for the SearchTable
class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var resultBtn: UIButton!
    
    var delegate: MealCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectMeal(_ sender: Any) {
        delegate?.didTapMeal(title: (resultBtn.currentTitle!))
    }
    

}
