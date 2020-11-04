//
//  ViewController.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 28/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import UIKit
import SQLite

//First time setup page
class SetupViewController: UIViewController {
    
    @IBOutlet weak var calorieInp: UITextField!
    @IBOutlet weak var calorieMetricInp: UISegmentedControl!
    @IBOutlet weak var weightInp: UITextField!
    @IBOutlet weak var weightMetricInp: UISegmentedControl!

    private let db = DBHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if db.getSettings() != [] {
            completedSetup()
        }
    }

    //Button pressed when user is done entering details for setup
    @IBAction func setup(_ sender: Any) {
        if calorieInp.text!.isEmpty {
            
            let alert = UIAlertController(title: "Please fill in valid values", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated:true, completion: nil)
            return
        }

        if weightInp.text!.isEmpty == false {
            if let input = weightInp.text?.double {
                if weightMetricInp.selectedSegmentIndex == 1 {
                    db.addWeight(weight: input/2.20)
                } else {
                    db.addWeight(weight: input)
                }
            } else {
                let alert2 = UIAlertController(title: "Please enter a valid value", message: "", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in alert2.dismiss(animated: true, completion: nil)}))
                self.present(alert2, animated:true, completion: nil)
                return
            }
        }
        var calorieInput = Int(calorieInp.text!)!
        
        if calorieMetricInp.selectedSegmentIndex == 1 {
            calorieInput = Int(round(Double(calorieInput)/4.18))
        }

        if db.setSettings(cal: calorieInput, calMet: calorieMetricInp.selectedSegmentIndex, weightMet: weightMetricInp.selectedSegmentIndex) {
            completedSetup()
        } else {
            print("Could not finish setup")
        }   
    }
    
    //Hadles changing of controllers
    func completedSetup() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        } else {
            let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            
            (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(mainTabBarController)
        }
    }
}

