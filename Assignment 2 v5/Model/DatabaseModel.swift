//
//  DatabaseModel.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 30/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//
import SQLite

struct MealsTable {
    let table = Table("meals")
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let cal = Expression<Int>("cal")
    let date = Expression<String>("date")
}

struct SettingsTable {
    let table = Table("settings")
    let id = Expression<Int>("id")
    let weightMetric = Expression<Int>("weightMetric")
    let calorieMetric = Expression<Int>("colorieMetric")
    let calGoal = Expression<Int>("calGoal")
}

struct WeightTable {
    let table = Table("weight")
    let id = Expression<Int>("id")
    let date = Expression<String>("date")
    let weight = Expression<Double>("weight")
}

