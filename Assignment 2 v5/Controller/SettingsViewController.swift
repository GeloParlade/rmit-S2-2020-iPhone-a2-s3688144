//
//  SettingsViewController.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 28/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var calorieMetric: UISegmentedControl!
    @IBOutlet weak var weightMetric: UISegmentedControl!

    private let db = DBHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = db.getSettings()
        goalTextField.text = String(db.getCalories(input: settings[2]))
        calorieMetric.selectedSegmentIndex = settings[0]
        weightMetric.selectedSegmentIndex = settings[1]
        // Do any additional setup after loading the view.
    }
    
    //Updates the Calorie Intake Goal
    @IBAction func updateGoal(_ sender: Any) {
        var newGoal = Int(goalTextField.text!)

        if db.getSettings()[0] == 1 {
            newGoal = Int(round(Double(newGoal!)/4.18))
        }

        if newGoal != db.getSettings()[2] {
            if db.updateSettings(cal: newGoal!, calMet: calorieMetric.selectedSegmentIndex, weightMet: weightMetric.selectedSegmentIndex) {
                print("Update Successful")
            } else {
                print("Could not finish update")
            }  
        }
    }
    
    //Updates the units of measurement used
    @IBAction func updateSettings(_ sender: Any) {
        if db.updateSettings(cal: db.getSettings()[2], calMet: calorieMetric.selectedSegmentIndex, weightMet: weightMetric.selectedSegmentIndex) {
            print("Update Successful")
            goalTextField.text = String(db.getCalories(input: db.getSettings()[2]))
        } else {
            print("Could not finish update")
        }  
    }
    
    //Delete all meal and weight records with a user confirmation prompt
    @IBAction func deleteRecords(_ sender: Any) {
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete all past records?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.db.clearRecords()
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
