//
//  WeightViewController.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 28/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import UIKit
import SQLite


class WeightViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var weightContainer: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var addMealBtn: UIButton!
    @IBOutlet weak var weightInput: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var selectedDate = Date()
    private let formatter = DateFormatter()
    private var db = DBHelper()
    private var data: [(Int,Double,String)] = []
    private var dbWeight = WeightTable()

    //Gets all the weights in the Weight table and stores it in the data array but only keeps weights inside the specifed date range
    func listWeights() {
        data = []

        do {
            let weights = try db.database.prepare(dbWeight.table)
            let formatter = DateFormatter()
            for weightdata in weights.reversed() {
                formatter.dateFormat = "HH:mm E, d MMM y"
                let sToDate = formatter.date(from: weightdata[dbWeight.date])!
                formatter.dateFormat = "MMMM yyyy"
                if(formatter.string(from: sToDate) == formatter.string(from: selectedDate)) {
                    data.append((weightdata[dbWeight.id],weightdata[dbWeight.weight],weightdata[dbWeight.date]))
                }
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    //Arranges the data array into the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell") as! WeightTableViewCell
        let weight = data[indexPath.row]
        
        formatter.dateFormat = "HH:mm E, d MMM y"
        let date = formatter.date(from: weight.2)!
        formatter.dateFormat = "dd.MM.yy"
        let month = formatter.string(from: date)
        formatter.dateFormat = "MMMM yyyy"

        cell.Weight.text = db.getWeight(input: weight.1)
        cell.date.text = month
           
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weightContainer.layer.cornerRadius = 10
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: Date())
        NotificationCenter.default.addObserver(self, selector: #selector(weightUpdated(notification:)), name: .weightChangeName, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        listWeights()
    }

    @objc func weightUpdated(notification: NSNotification) {
        listWeights()
    }
    
    @IBAction func forwardMonth(_ sender: Any) {
        let prevMonth = Calendar.current.date(byAdding: .month, value: 1, to: self.selectedDate)!
        self.selectedDate = prevMonth
        dateChange()
    }
    
    @IBAction func backMonth(_ sender: Any) {
        let nextMonth = Calendar.current.date(byAdding: .month, value: -1, to: self.selectedDate)!
        self.selectedDate = nextMonth
        dateChange()
    }
    
    func dateChange() {
        if formatter.string(from: Date()) == formatter.string(from: selectedDate) {
            addMealBtn.isEnabled = true
            forwardBtn.isEnabled = false
            forwardBtn.setTitleColor(UIColor.systemGray, for: .normal)
        } else {
            forwardBtn.isEnabled = true
            forwardBtn.setTitleColor(UIColor.systemBlue, for: .normal)
            addMealBtn.isEnabled = false
        }
        monthLabel.text = formatter.string(from: selectedDate)
        listWeights()
    }
    
    @IBAction func addWeight(_ sender: Any) {
        if weightInput.text!.isEmpty {
            let alert = UIAlertController(title: "Please fill in your weight", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated:true, completion: nil)
            return
        }
        if let input = weightInput.text?.double {
            if db.getSettings()[1] == 1 {
                db.addWeight(weight: input/2.20)
            } else {
                db.addWeight(weight: Double(weightInput.text!)!)
            }
        } else {
            let alert2 = UIAlertController(title: "Please enter a valid value", message: "", preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in alert2.dismiss(animated: true, completion: nil)}))
            self.present(alert2, animated:true, completion: nil)
            return
        }
        weightInput.text = ""
        weightInput.resignFirstResponder()
        listWeights()
    }

}

//Checks if string can be casted to double
extension StringProtocol {
    var double: Double? { Double(self) }
}


