//
//  AddMealViewController.swift
//  Assignment 2 v3
//
//  Created by Angelo Parlade on 23/9/20.
//  Copyright © 2020 Angelo Parlade. All rights reserved.
//

import UIKit
import Foundation

class AddMealViewContoller: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var calInput: UITextField!
    @IBOutlet weak var servingInput: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var statusIndicator: UIActivityIndicatorView!
    
    private var data: [(String,Int)] = []
    private var indicator = UIActivityIndicatorView()
    private let db = DBHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.layer.borderWidth = 0.5
        statusIndicator.isHidden = true
        searchBar.delegate = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        nameInput.delegate = self
    }
    
    //Progress of searching for keyword using the FoodAPI
    //Todo - Bug
    //Status indicator doesnt disappear and show results until user interacts with screen such as scrolling or tapping a button
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        indicator.center = self.view.center
        indicator.color = UIColor.systemBlue
        indicator.backgroundColor = UIColor.gray
        self.view.addSubview(indicator)
    }

    //Disimisses keyboard if done is returned by keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Starts the process of searching the food using the API
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if (searchBar.text == "") {
            data = []
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
        } else {
            statusIndicator.startAnimating()
            statusIndicator.isHidden = false
            nutritionAPI(search: searchBar.text!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    //Arranges the data received from the API into the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultsCell") as! SearchTableViewCell
        
        let meal = data[indexPath.row]
        var metric = " cal"
        cell.tag = indexPath.row
        if db.getSettings()[0] == 1 {
            metric = " kj "
        }
        
        cell.resultBtn.setTitle(meal.0 + " - " + String(self.db.getCalories(input: meal.1)) + metric, for: .normal)
        
        cell.delegate = self
        return cell
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        NotificationCenter.default.post(name: .mealChanged, object: nil)
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Creates a user alert prompt
    //Todo
    //No longer needed as its own function since it is only used once unlike earlier versions
    func createAlert (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated:true, completion: nil)
    }
    
    //Checks if all input data is valid and then adds it to the meals table
    @IBAction func addManually(_ sender: Any) {
        if nameInput.text!.isEmpty || calInput.text!.isEmpty || servingInput.text!.isEmpty{
            let alert = UIAlertController(title: "Please fill in all values", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated:true, completion: nil)
            return
        }
        var cal:Int? = Int(calInput.text!)
        if db.getSettings()[0] == 1 {
            cal = Int(round(Double(cal!)/4.18))
        }
        let serving:Int? = Int(servingInput.text!)
        let totalCal = cal! * serving!

        db.addMeal(totalCal: totalCal, name: nameInput.text!)

        NotificationCenter.default.post(name: .mealChanged, object: nil)
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Search function using the API
    func nutritionAPI(search: String) {
        self.data = []
        let headers = [
            "x-rapidapi-host": "edamam-food-and-grocery-database.p.rapidapi.com",
            "x-rapidapi-key": "aa6ffc8f13msh26bfcfe70169405p101eeajsnde01052c2ea0"
        ]
        
        let link = search.replacingOccurrences(of: " ", with: "%20")
        let request = NSMutableURLRequest(url: NSURL(string: "https://edamam-food-and-grocery-database.p.rapidapi.com/parser?ingr=" +
            link)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil || data == nil) {
                self.data = []
                self.refreshTable()
            } else {
                do {
                    let JSONData = try JSONDecoder().decode(JSONResult.self, from: data!)

                    let parsed = JSONData.parsed
                    let hints = JSONData.hints
                    
                    for result in parsed {
                        let name = result.food.label
                        let calo = result.food.nutrients.ENERC_KCAL
                        if name != nil && calo != nil {
                            self.data.append((name!, Int(calo)))
                        }
                    }
                    
                    for result in hints {
                        let name = result.food.label
                        let calo = result.food.nutrients.ENERC_KCAL
                        if name != nil && calo != nil {
                            self.data.append((name!, Int(calo)))
                        }
                    }
                    self.refreshTable()
                    
                } catch 
                
                {
                    print(error)
                }

            }
        })
        dataTask.resume()
    }
    
    //Refreshes the table when results are received
    //Todo - Bug: Elaborated above
    func refreshTable() {
        OperationQueue.main.addOperation(){
            self.formatResult()
            self.searchTableView.reloadData()
            self.statusIndicator.stopAnimating()
            self.statusIndicator.hidesWhenStopped = true
        }
        
    }

    //Formats the data received and combines similar results into one
    func formatResult() {
        var names:[String] = []
        var cal:[[Int]] = []
        for result in data {
            
            if let index = names.firstIndex(of: result.0.uppercased()) {
                cal[index].append(result.1)
            } else {
                names.append(result.0.uppercased())
                cal.append([result.1])
            }
        }
        data = []
        for (index, value) in names.enumerated() {
            data.append((value, (cal[index].reduce(0, +) / cal[index].count)))
        }
    }
    
}

//Gets the data from the title of the selected tile and inputs it into the textfields
extension AddMealViewContoller: MealCellDelegate {
    func didTapMeal(title: String) {
        let strArray = title.components(separatedBy: " - ")
        nameInput.text = strArray[0]
        var temp = strArray[1].dropLast()
        temp = temp.dropLast()
        temp = temp.dropLast()
        temp = temp.dropLast()
        calInput.text = String(temp)
    }
}
