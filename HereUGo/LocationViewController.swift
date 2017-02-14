//
//  LocationViewController.swift
//  HereUGo
//
//  Created by redBred LLC on 2/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import MapKit

protocol LocationViewControllerDelegate {
    func onLocationPicked(latitude: Double, longitude: Double, triggerWhenLeaving: Bool, locationName: String?, addressDescription: String?, range: Int)
    func getTriggerWhenLeaving() -> Bool
    func setTriggerWhenLeaving(whenLeaving: Bool)
    func getTriggerLocation
}

class LocationViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchBarContainerView: UIView!
    @IBOutlet var arriveOrLeaveSegmentedControl: UISegmentedControl!
    
    var delegate: LocationViewControllerDelegate? = nil
    
    // will handle fetching location info
    lazy var locationManager: LocationManager = {
        return LocationManager(alertPresentingViewController: self)
    }()
    
    lazy var resultsTableController: SearchResultsTableViewController = {
        
        let rc = self.storyboard!.instantiateViewController(withIdentifier: "SearchResults") as! SearchResultsTableViewController
        rc.tableView.delegate = self
        
        return rc
    }()
    
    lazy var searchController: UISearchController = {
        
        let sc = UISearchController(searchResultsController: self.resultsTableController)
        sc.searchResultsUpdater = self
        sc.searchBar.sizeToFit()

        sc.delegate = self
        sc.hidesNavigationBarDuringPresentation = false
        sc.dimsBackgroundDuringPresentation = true
        
        self.definesPresentationContext = true
        
        return sc
    }()
    
    var selectedPin: MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.getLocation { (location) in
            
            print("Location: \(location)")

            self.setMapViewRegion(coordinate: location.coordinate)
        }
        
        refreshArriveOrLeaveSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBarContainerView.addSubview(searchController.searchBar)
    }
    
    func setMapViewRegion(coordinate: CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        mapView.setRegion(region, animated: true)
    }
    
    func refreshArriveOrLeaveSegmentedControl() {
        
        if let triggerWhenLeaving = delegate?.getTriggerWhenLeaving(), triggerWhenLeaving {
            arriveOrLeaveSegmentedControl.selectedSegmentIndex = 1
        } else {
            arriveOrLeaveSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    func isTriggerWhenLeaving() -> Bool {
        
        if arriveOrLeaveSegmentedControl.selectedSegmentIndex == 1 {
            return true
        }
        
        return false
    }
}



// Mark - IBActions
extension LocationViewController {
    @IBAction func onArriveOrLeaveDidChange() {
        delegate?.setTriggerWhenLeaving(whenLeaving: isTriggerWhenLeaving())
    }
}



extension LocationViewController: UISearchControllerDelegate {
}

extension LocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let placemark = resultsTableController.searchResults[indexPath.row].placemark
        
        // send the info back to the delegate
        delegate?.onLocationPicked(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude, triggerWhenLeaving: isTriggerWhenLeaving(), locationName: placemark.name, addressDescription: placemark.prettyDescription, range: 50)
        
        // display the placemark on the map
        presentMapViewWithPlacemark(placemark: placemark)
    }
    
    func presentMapViewWithPlacemark(placemark: MKPlacemark) {
        
        selectedPin = placemark
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        mapView.addAnnotation(annotation)
        
        self.setMapViewRegion(coordinate: placemark.coordinate)
        
        // present mapView
        dismiss(animated: true, completion: nil)
    }
}

extension LocationViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let mapView = mapView, let searchText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            
            guard let response = response else { return }
            
            self.resultsTableController.searchResults = response.mapItems
            self.resultsTableController.tableView.reloadData()
        }
    }
}
