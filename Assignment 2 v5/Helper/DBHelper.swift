//
//  DBHelper.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 28/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import Foundation
import SQLite

class DBHelper {
    public var database: Connection!
    private let dbMeal = MealsTable()
    private let dbWeight = WeightTable()
    private let dbSettings = SettingsTable()
    private let today = Date()
    private let formatter = DateFormatter()
    
    init() {
        connectDatabase()
    }
    
    func connectDatabase() {
        //Connecting to local database
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("calDiary").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        //Creates tables if doest exists
        let createTable = [(MealsTable().table.create { (table) in
            table.column(dbMeal.id, primaryKey: true)
            table.column(dbMeal.name)
            table.column(dbMeal.date)
            table.column(dbMeal.cal)
        }),(WeightTable().table.create { (table) in
            table.column(dbWeight.id, primaryKey: true)
            table.column(dbWeight.date)
            table.column(dbWeight.weight)
        }),(SettingsTable().table.create { (table) in
            table.column(dbSettings.id, primaryKey: true)
            table.column(dbSettings.calGoal)
            table.column(dbSettings.weightMetric)
            table.column(dbSettings.calorieMetric)
        })]
        
        for table in createTable {
            do {
                try self.database.run(table)
            } catch {
                print(error)
            }
        }
    }
    
    //Add a meal to the database
    func addMeal(totalCal:Int, name:String) {
        formatter.dateFormat = "HH:mm E, d MMM y"
        let insertMeal = dbMeal.table.insert(dbMeal.name <- name, dbMeal.cal <- totalCal, dbMeal.date <- self.formatter.string(from: today))
        
        do {
            try self.database.run(insertMeal)
        } catch {
            print(error)
        }
    }
    
    //Delete all existing food and weight data
    func clearRecords() {
        do {
            try self.database.run(dbMeal.table.drop(ifExists: true))
            try self.database.run(dbWeight.table.drop(ifExists: true))
            connectDatabase()
        } catch {
            print(error)
        }
    }
    
    //Update Calorie Intake Goal and metrics used for measurement
    func setSettings(cal: Int, calMet: Int, weightMet: Int) -> Bool{
        let insertSettings = dbSettings.table.insert(dbSettings.weightMetric <- weightMet, dbSettings.calorieMetric <- calMet, dbSettings.calGoal <- cal)
        do {
            try self.database.run(insertSettings)
            return true
        } catch {
            return false
        }
    }
    
    //Update details of a meal
    func updateMeal(index: Int, name: String, cal: Int) {
        let updateMeal = dbMeal.table.filter(dbMeal.id==index).update(dbMeal.name <- name, dbMeal.cal <- cal)
        do {
            try self.database.run(updateMeal)
        } catch {
            print(error)
        }
    }
    
    //Delete a record of a meal
    func deleteMeal(index: Int) {
        let updateMeal = dbMeal.table.filter(dbMeal.id==index).delete()
        do {
            try self.database.run(updateMeal)
        } catch {
            print(error)
        }
    }
    
    //Update Calorie Intake Goal and metrics used for measurement
    func updateSettings(cal: Int, calMet: Int, weightMet: Int) -> Bool{
        let insertSettings = dbSettings.table.filter(dbSettings.id==1).update(dbSettings.weightMetric <- weightMet, dbSettings.calorieMetric <- calMet, dbSettings.calGoal <- cal)
        do {
            try self.database.run(insertSettings)
            return true
        } catch {
            return false
        }
    }
    
    //Add current weight to the database
    func addWeight(weight: Double) {
        formatter.dateFormat = "HH:mm E, d MMM y"
        let insertWeight = dbWeight.table.insert(dbWeight.weight <- weight, dbWeight.date <- formatter.string(from: today))
        
        do {
            try self.database.run(insertWeight)
        } catch {
            print(error)
        }
    }
    
    //Accepts a weight in kgs and returns it in lbs depending on settings
    func getWeight(input:Double) -> String {
        if self.getSettings()[1] == 1 {
            return String(format: "%.2f", (input*2.20))
        } else {
            return String(format: "%.2f", (input))
        }
    }
    
    //Accepts a calorie metric in cal and returns it in kj depending on settings
    func getCalories(input:Int) -> Int {
        if self.getSettings()[0] == 1 {
            return (Int(Double(input)*4.184))
        } else {
            return input
        }
    }
    
    //Returns current settings
    func getSettings() -> [Int] {
        var data:[Int] = []
        
        do {
            let settings = try self.database.prepare(self.dbSettings.table)
            for setting in settings {
                data.append(setting[dbSettings.calorieMetric])
                data.append(setting[dbSettings.weightMetric])
                data.append(setting[dbSettings.calGoal])
            }
        } catch {
            print(error)
        }
        return data
    }
    
}

//Notifications used to send signals to update table if data has changed
extension Notification.Name {
    static let weightChangeName = Notification.Name("weightChangeName")
    static let mealChanged = Notification.Name("mealChanged")
}
