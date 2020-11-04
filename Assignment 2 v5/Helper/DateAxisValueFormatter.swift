//
//  DateAxisValueFormatter.swift
//  Assignment 2 v5
//
//  Created by Angelo Parlade on 4/11/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//
import UIKit
import Foundation
import Charts

//For converting dates in the form of seconds into a date.
//Used on x-axis of charts
class DateAxisValueFormatter : NSObject, IAxisValueFormatter {
    let dateFormatter = DateFormatter()
    let secondsPerDay = 24.0 * 3600.0
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM"
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value * secondsPerDay)
        return dateFormatter.string(from: date)
    }
}
