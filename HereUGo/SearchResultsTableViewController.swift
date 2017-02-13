//
//  SearchResultsTableViewController.swift
//  HereUGo
//
//  Created by redBred LLC on 2/10/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import MapKit
class SearchResultsTableViewController: UITableViewController {

    var searchResults: [MKMapItem] = []
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        
        let placemark = searchResults[indexPath.row].placemark
        
        cell.textLabel?.text = placemark.name
        cell.detailTextLabel?.text = placemark.prettyDescription
        
        return cell
    }
}
