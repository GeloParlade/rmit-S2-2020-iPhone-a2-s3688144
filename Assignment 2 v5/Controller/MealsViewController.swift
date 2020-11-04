//
//  MealsViewController.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 23/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import UIKit
import SQLite

class MealsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var mealContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var forwardDateBtn: UIButton!
    @IBOutlet weak var addMealBtn: UIButton!
    @IBOutlet weak var goalCal: UILabel!
    @IBOutlet weak var foodCal: UILabel!
    @IBOutlet weak var remainingCal: UILabel!
    
    
    private var data: [(Int,String,String,Int)] = []
    private let db = DBHelper()
    private  var selectedDate = Date()
    private var selectedCell:(Int,Int) = (0,0)
    private var dbMeal = MealsTable()
    private var IDs: [Int] = []
    private var names: [String] = []
    private var calories: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayLabel.text="Today"
        mealContainer.layer.cornerRadius = 10
        
        //Listens for notifications regarding data updates on the meals table
        NotificationCenter.default.addObserver(self, selector: #selector(mealUpdated(notification:)), name: .mealChanged, object: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        listMeals()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    //Refreshes the table
    @objc func mealUpdated(notification: NSNotification) {
         listMeals()
         tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    //Arranges the data received into the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell") as! MealTableViewCell
        
        let meal = data[indexPath.row]
        
        let text = meal.1
        let dateString = meal.2
        let cal = meal.3
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        let date = formatter.date(from: dateString)!
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: date)
        
        cell.mealName.text = text
        cell.mealTime.text = time
        cell.mealCal.text = String(db.getCalories(input:cal))
           
        return cell
    }
    
    //Chages views according to the table cell selected
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! EditMealViewController
                controller.selectedCell = (IDs[indexPath.row], names[indexPath.row], calories[indexPath.row])
            }
        }
    }
    
    //Updates the data received from meals table
    func listMeals() {
        data = []
        IDs = []
        names = []
        calories = []
        goalCal.text = String(db.getCalories(input:(db.getSettings()[2])))
        var totalCal: Int = 0
        
        do {
            let meals = try db.database.prepare(dbMeal.table)
            let formatter = DateFormatter()
            for meal in meals.reversed() {
                formatter.dateFormat = "HH:mm E, d MMM y"
                let sToDate = formatter.date(from: meal[dbMeal.date])!
                formatter.dateStyle = .short
                var selectedDate = dayLabel.text
                if(dayLabel.text == "Today") {
                    let today = Date()
                    selectedDate = formatter.string(from: today)
                }
                if(formatter.string(from: sToDate) == selectedDate) {
                    IDs.append(meal[dbMeal.id])
                    names.append(meal[dbMeal.name])
                    calories.append(meal[dbMeal.cal])
                    data.append((meal[dbMeal.id],meal[dbMeal.name],meal[dbMeal.date],meal[dbMeal.cal]))
                    totalCal += meal[dbMeal.cal]
                }
            }
            totalCal = db.getCalories(input: totalCal)
            foodCal.text = String(totalCal)
            let total = Int(goalCal.text!)! - totalCal
            remainingCal.text = String(total)
            
        } catch {
            print(error)
        }
    }
    
    @IBAction func backDate(_ sender: Any) {
        let prevDay = Calendar.current.date(byAdding: .day, value: -1, to: self.selectedDate)!
        self.selectedDate = prevDay
        dateChange()
    }
    
    @IBAction func forwardDate(_ sender: Any) {
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: self.selectedDate)!
        self.selectedDate = nextDay
        dateChange()
    }
    
    func dateChange() {
        print(selectedDate)
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        if formatter1.string(from: selectedDate) == formatter1.string(from: Date()) {
            dayLabel.text = "Today"
            addMealBtn.isEnabled = true
            forwardDateBtn.isEnabled = false
            forwardDateBtn.setTitleColor(UIColor.systemGray, for: .normal)
        } else {
            forwardDateBtn.isEnabled = true
            forwardDateBtn.setTitleColor(UIColor.systemBlue, for: .normal)
            addMealBtn.isEnabled = false
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
            dayLabel.text = formatter1.string(from: selectedDate)
        }
        listMeals()
        tableView.reloadData()
    }
    
    
    
}
