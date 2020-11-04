//
//  EditMealViewController.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 30/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import UIKit
import SQLite

class EditMealViewController: UIViewController {
    
    @IBOutlet weak var nameTextFeild: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    
    public var selectedCell: (Int, String, Int) = (0, "", 0)
    private let db = DBHelper()
    
    @IBAction func update(_ sender: Any) {
        var cal = Int(caloriesTextField.text!)
        if db.getSettings()[0] == 1 {
            cal = Int(round(Double(cal!)/4.18))
        }
        db.updateMeal(index: selectedCell.0, name: nameTextFeild.text!, cal: cal!)
        close()
    }
    
    @IBAction func deleteMeal(_ sender: Any) {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete all past records?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.db.deleteMeal(index: self.selectedCell.0)
            self.close()
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
               
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedCell)
        nameTextFeild.text = selectedCell.1
        caloriesTextField.text = String(db.getCalories(input: selectedCell.2))
        // Do any additional setup after loading the view.
    }
    
    //Returns to the MealsView
    func close() {
        NotificationCenter.default.post(name: .mealChanged, object: nil)
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        close()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
