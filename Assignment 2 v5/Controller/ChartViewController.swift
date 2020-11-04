//
//  ChartViewController.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 28/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import UIKit
import Charts
import SQLite

class ChartViewController: UIViewController {

    @IBOutlet weak var range: UILabel!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var chtChart: LineChartView!
    private var data: [(Date, Double)] = []
    private var db = DBHelper()
    private var selectionText = ["7 Days", "2 Weeks", "1 Month", "6 Months", "1 Year", "All Time"]
    private var selectionInt = [7, 14, 30, 180, 365, 3650]
    private var currentSelection = 0
    private let dbMeal = MealsTable()
    private let dbWeight = WeightTable()
    private let dbSettings = SettingsTable()
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        loadData()
    }
    
    //Creates a chart based on the data array and displays it in the view
    func loadChart() {
        var lineChartEntry  = [ChartDataEntry]()
        
        for i in data {
            let value = ChartDataEntry(x: i.0.timeIntervalSince1970, y: i.1)
            lineChartEntry.append(value)
        }
        lineChartEntry.sort(by: { $0.x < $1.x })
        var label = "Total Calories per day"
        if segment.selectedSegmentIndex == 1 {
            label = "Average Weight per day"
        }
        
        let line1 = LineChartDataSet(entries: lineChartEntry, label: label)
        let chartData = LineChartData()
        chartData.addDataSet(line1)
        chtChart.data = chartData
        chtChart.rightAxis.drawLabelsEnabled = false
        chtChart.xAxis.drawLabelsEnabled = false
    }
    
    //Returns the average of a Array
    func average(input: [Double]) -> Double {
        var total = input.reduce(0, +)
        total = total / Double(input.count)
        total = Double(String(format: "%.2f", total))!
        return total
    }
    
    //Requests annd updates the data variable depending on whether weight or calories is aked for
    func loadData() {
        data = []
        do {
            var currentDateEnrty = Date()
            var inputs:[Double] = []
            var database = try db.database.prepare(dbMeal.table)
            if segment.selectedSegmentIndex == 1 {
                database = try db.database.prepare(dbWeight.table)
            }
            for info in database {
                formatter.dateFormat = "HH:mm E, d MMM y"
                let sToDate = formatter.date(from: info[dbMeal.date])!
                formatter.dateFormat = "MMM d, yyyy"
                if Calendar.current.dateComponents([.day], from: sToDate, to: Date()).day! >= selectionInt[currentSelection] {
                    continue
                }
                if(formatter.string(from: sToDate) == formatter.string(from: currentDateEnrty)) {
                    if segment.selectedSegmentIndex == 0 {
                        inputs.append(Double(db.getCalories(input: info[dbMeal.cal])))
                    } else {
                        inputs.append(Double(db.getWeight(input: info[dbWeight.weight]))!)
                    }
                } else {
                    if inputs.isEmpty == false {
                        if segment.selectedSegmentIndex == 0 {
                            data.append((currentDateEnrty,inputs.reduce(0, +)))
                        } else {
                            data.append((currentDateEnrty,average(input: inputs)))
                        }
                        inputs = []
                    }
                    currentDateEnrty = sToDate
                }
            }
            if segment.selectedSegmentIndex == 0 {
                data.append((currentDateEnrty,inputs.reduce(0, +)))
            } else {
                data.append((currentDateEnrty,average(input: inputs)))
            }
            loadChart()
        } catch {
            print(error)
        }
    }
    
    @IBAction func forward(_ sender: Any) {
        currentSelection -= 1
        range.text = selectionText[currentSelection]
        backBtn.isEnabled = true
        backBtn.setTitleColor(UIColor.systemBlue, for: .normal)
        if currentSelection == 0 {
            forwardBtn.isEnabled = false
            forwardBtn.setTitleColor(UIColor.systemGray, for: .normal)
        }
        loadData()
    }
    
    @IBAction func back(_ sender: Any) {
        currentSelection += 1
        range.text = selectionText[currentSelection]
        forwardBtn.isEnabled = true
        forwardBtn.setTitleColor(UIColor.systemBlue, for: .normal)
        if currentSelection == 5 {
            backBtn.isEnabled = false
            backBtn.setTitleColor(UIColor.systemGray, for: .normal)
        }
        loadData()
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
