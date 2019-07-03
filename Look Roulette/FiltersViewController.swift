//
//  FiltersViewController.swift
//  Look Roulette
//
//  Created by Cortland Walker on 7/2/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {
    
    // The list of filters inside the Filters Table
    var filters = [String]()
    
    // String representation of the filters created in the tableview. Separated with a space.
    var allFiltersStringText: String = ""
    
    @IBOutlet weak var _addFilterText: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addFilterButton(_ sender: Any) {
        insertFilter()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    /*
     * Function used to append a filter to table view.
     */
    func insertFilter() {
        
        if _addFilterText.text == "" {
            print("Add Video Text Field is empty")
        } else {
            filters.append(_addFilterText.text!)
            
            let indexPath = IndexPath(row: filters.count - 1, section: 0)
            
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            _addFilterText.text = ""
            view.endEditing(true)
            
            tableView.isHidden = false
        }
    }

}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filterTitle = filters[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") as! FilterCell
        cell._filterText.text = filterTitle
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            filters.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
    }
    
    
}
