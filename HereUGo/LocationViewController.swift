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
    func setTriggerWhenLeaving(whenLeaving: Bool)
    func setRange(range: Int)
    func currentTriggerLocation() -> TriggerLocation?
}

class LocationViewController: UIViewController {

    static let initialRadius: Int = 50
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchBarContainerView: UIView!
    @IBOutlet var arriveOrLeaveSegmentedControl: UISegmentedControl!
    @IBOutlet var rangeLabel: UILabel!
    @IBOutlet var rangeSlider: UISlider!
    
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
    
    var currentPin: MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if let delegate = delegate, let location = delegate.currentTriggerLocation() {
            
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            
            addMapAnnotationForPlacemark(placemark: placemark, radius: Int(location.range), overwriteName: location.name)
            
        } else {
            
            locationManager.getLocation { (location) in
                
                print("Location: \(location)")
                
                self.setMapViewRegion(coordinate: location.coordinate)
            }
        }
        
        refreshArriveOrLeaveSegmentedControl()
        refreshRangeComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBarContainerView.addSubview(searchController.searchBar)
    }
    
    func setMapViewRegion(coordinate: CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        mapView.setRegion(region, animated: true)
    }
    
    func refreshArriveOrLeaveSegmentedControl() {
        
        if let location = delegate?.currentTriggerLocation(), location.triggerWhenLeaving {
            arriveOrLeaveSegmentedControl.selectedSegmentIndex = 1
        } else {
            arriveOrLeaveSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    func refreshRangeComponents() {
        
        if let location = delegate?.currentTriggerLocation() {
            
            rangeLabel.text = "\(location.range)"
            rangeSlider.value = Float(Int(location.range))
        }
    }
    
    func isTriggerWhenLeaving() -> Bool {
        
        if arriveOrLeaveSegmentedControl.selectedSegmentIndex == 1 {
            return true
        }
        
        return false
    }
    
    func addMapAnnotationForPlacemark(placemark: MKPlacemark, radius: Int, overwriteName: String?) {
        
        // keep for later :-)
        currentPin = placemark
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = overwriteName ?? placemark.name
        
        mapView.addAnnotation(annotation)
        
        self.setMapViewRegion(coordinate: placemark.coordinate)

        updateMapCircleForCurrentPin(radius: radius)
    }
}



// Mark - IBActions
extension LocationViewController {
    
    @IBAction func onArriveOrLeaveDidChange() {
        delegate?.setTriggerWhenLeaving(whenLeaving: isTriggerWhenLeaving())
    }

    @IBAction func onRangeSliderChanged(_ sender: UISlider) {
        
        let range = Int(sender.value)
        
        rangeLabel.text = "\(range)"
        delegate?.setRange(range: range)
        updateMapCircleForCurrentPin(radius: range)
    }
}



extension LocationViewController: UISearchControllerDelegate {
}

extension LocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let placemark = resultsTableController.searchResults[indexPath.row].placemark
        
        // send the info back to the delegate
        delegate?.onLocationPicked(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude, triggerWhenLeaving: isTriggerWhenLeaving(), locationName: placemark.name, addressDescription: placemark.prettyDescription, range: LocationViewController.initialRadius)
        
        // display the placemark on the map
        presentMapViewWithPlacemark(placemark: placemark, radius: LocationViewController.initialRadius)
    }
    
    func presentMapViewWithPlacemark(placemark: MKPlacemark, radius: Int) {
        
        addMapAnnotationForPlacemark(placemark: placemark, radius: radius, overwriteName:  nil)
        
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

extension LocationViewController: MKMapViewDelegate {
    
    func updateMapCircleForCurrentPin(radius: Int) {

        // clear out old overlays
        mapView.removeOverlays(mapView.overlays)
        
        if let pin = currentPin {
            
            let circle = MKCircle(center: pin.coordinate, radius: Double(radius) as CLLocationDistance)
            mapView.add(circle)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return MKPolylineRenderer()
        }
    }
}







