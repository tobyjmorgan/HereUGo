//
//  ReminderCell.swift
//  HereUGo
//
//  Created by redBred LLC on 2/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import CoreLocation

class ReminderCell: UITableViewCell {

    @IBOutlet var cellContainerView: UIView!
    @IBOutlet var checkboxButton: UIButton!
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var subLabel: UILabel!
    @IBOutlet var disclosureImage: UIImageView!
    
    let geocoder = CLGeocoder()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellContainerView.layer.cornerRadius = 10
        self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setLocation(latitude: Double, longitude: Double, triggerWhenEntering: Bool) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            // make sure this happens on the main queue
            // just in case there is any GUI code inside the completion handler
            DispatchQueue.main.async {
                
                guard let placemark = placemarks?.first else { return }
  
                self.subLabel.text = "Alert at: \(placemark.prettyDescription)"
            }
            
        }
    }

    func resetCell() {
        mainLabel.text = ""
        subLabel.text = ""        
    }

    @IBAction func onCheckBox(_ sender: Any) {
        checkboxButton.isSelected = !checkboxButton.isSelected
    }
}
