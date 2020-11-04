//
//  FoodAPI.swift
//  Assignment 2 v5
//
//  Created by Angelo Parlade on 4/11/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

struct JSONResult: Codable {
    var parsed: [JSONFood]
    var hints: [JSONFood]
}

struct JSONFood: Codable {
    var food: Food
}

struct Food: Codable {
    var label: String?
    var nutrients: Nutrients
}

struct Nutrients: Codable {
    var ENERC_KCAL: Float
}
