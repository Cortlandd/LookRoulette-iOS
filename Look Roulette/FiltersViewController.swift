//
//  FiltersViewController.swift
//  Look Roulette
//
//  Created by Cortland Walker on 7/2/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import UIKit

protocol FiltersSavedDelegate: class {
    func querySaved(query: String)
}

class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersSavedDelegate? = nil
    
    // The list of filters inside the Filters Table
    var filters = [String]()
    
    var allFiltersText: [String]?
    
    // String representation of the filters created in the tableview. Separated with a space.
    var allFiltersStringText: String?
    
    var filterDefaults: FilterDefaults!
    
    @IBOutlet weak var _saveButton: UIBarButtonItem!
    
    
    @IBOutlet weak var _addFilterButton: UIButton!
    
    @IBOutlet weak var _addFilterText: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var _baseSearchText: UITextField!
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        let baseSearch = _baseSearchText.text
        
        allFiltersStringText = allFiltersText?.joined(separator: " ")
        
        let search = "\(baseSearch?.description ?? "") \(allFiltersStringText ?? "")"
        
        // Pass image
        delegate?.querySaved(query: search)
        
        UserDefaults.standard.set(search, forKey: "FullSearchQuery")
        
        // Gotta be a better way of doing this
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addFilterButton(_ sender: Any) {
        insertFilter(filterText: _addFilterText.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterDefaults = FilterDefaults()
        
        filters.append(contentsOf: filterDefaults.getFilters())

        _baseSearchText.addTarget(self, action: #selector(tappedBaseSearchText), for: .allEditingEvents)
        _addFilterText.addTarget(self, action: #selector(filterTextListener), for: .allEditingEvents)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
    }
    

    /*
     * Function used to append a filter to table view.
     */
    func insertFilter(filterText: String) {
        
        if _addFilterText.text == "" {
            
            print("Add Video Text Field is empty")
            
        } else {
            
            filterDefaults.addFilter(filter: filterText)
            
            filters.removeAll()
            
            filters.append(contentsOf: filterDefaults.getFilters())
            
            tableView.reloadData()
            
            _addFilterText.text = ""
            
            view.endEditing(true)
            
            // After inserting a new row, get the newly visible filters
            allFiltersText = getAllTableViewRowsText()
            
            if _saveButton.isEnabled == false {
                _saveButton.isEnabled = true
            }
            
            tableView.isHidden = false
        }
    }
    
    /*
     * For each visible tablecell, put the text into an array and return it
     */
    func getAllTableViewRowsText() -> [String] {
        var r = [String]()
        
        for cell in tableView.visibleCells as! [FilterCell] {
            r.append(cell._filterText.text!)
        }
        return r
    }
    
    /*
     * Validate the base search isn't the base or empty
     */
    @objc func tappedBaseSearchText() {
        if _baseSearchText.text == "Makeup Tutorials" || _baseSearchText.text == "" {
            _saveButton.isEnabled = false
        } else {
            _saveButton.isEnabled = true
        }
    }
    
    @objc func filterTextListener() {
        if _addFilterText.text == "" {
            _addFilterButton.isEnabled = false
        } else {
            _addFilterButton.isEnabled = true
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
            
            filterDefaults.removeFilter(index: indexPath.row)
            
            filters.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            if _saveButton.isEnabled == false {
                _saveButton.isEnabled = true
            }
            
            tableView.reloadData()
        }
        
        // After deleting a row, get the newly visible filters
        allFiltersText = getAllTableViewRowsText()
    }
    
    
}
