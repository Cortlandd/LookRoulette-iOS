//
//  LooksTableViewController.swift
//  Look Roulette
//
//  Created by Cortland Walker on 6/29/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import UIKit

class LooksTableViewController: UITableViewController {
    
    @IBOutlet weak var _looksLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var _noResultsView: UIView!
    
    /* TODO's:
     Implement pull down refresh
     */
    
    // YouTube API Key
    // Place this somewhere else
    var API_SEARCH_KEY: String = "AIzaSyCyhv7a5gFLkEBVRDU8DKmBcSuMPmMyCoU"
    
    var searchResults: [Items]!
    
    var nextPageToken: String = ""
    
    var networkManager: NetworkManager!
    
    var baseSearchQuery: String = "makeup tutorials"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableInit()
        
        networkManager = NetworkManager()
        
        searchResults = [Items]()
        
        searchVideo()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func searchVideo() {
        
        self._looksLoadingIndicator.isHidden = false
        
        var search_params: Parameters = [
            "q": "\(baseSearchQuery)",
            "part": "snippet",
            "key": API_SEARCH_KEY,
            // Get maximum amount of results to reduce api usage and quota maximizing
            // Will need to update thumbnail image downloader
            "maxResults": 50,
            "pageToken": nextPageToken,
            "safeSearch": "none",
            "type": "video"
        ]
        
        networkManager.searchVideoItems(params: search_params) { response, error in
            
            if let error = error {
                print(error)
            }
            
            if let res = response {
                self.nextPageToken = res.nextPageToken
                self.searchResults.append(contentsOf: res.items)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self._looksLoadingIndicator.isHidden = true
                }
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "LookDetails":
            if let row = tableView.indexPathForSelectedRow?.row {
                let video = searchResults[row]
                let items = getItemFromId(videoId: video.id.videoId)
                
                let looksDetailViewController = segue.destination as! LookDetailsViewController
                looksDetailViewController.items = items
            }
        case "LookFilters":
            print("Hello")
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    func getBaseSearchQuery() -> String {
        return baseSearchQuery
    }
    
    func getItemFromId(videoId: String) -> Items {
        var h = [Items]()
        for i in searchResults {
            if i.id.videoId == videoId {
                h.append(i)
            }
        }
        return h[0]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row + 1 == searchResults.count {
            // TODO: Setup 1 second delay
            searchVideo()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LooksImageCell", for: indexPath) as! LooksImageCell
        
        let video = searchResults[indexPath.row]
        let url = URL(string: video.snippet.thumbnails.high.url)
        
        if url != nil {
            cell._thumbnailImage.load(url: url!)
        }

        return cell
    }
    
    func tableInit() {
        // Remove lines
        tableView.separatorStyle = .none
        
        // Set row height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        // CLEAN UP NO RESULT
        //tableView.backgroundView = _noResultsView
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
