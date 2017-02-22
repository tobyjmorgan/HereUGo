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

    var onButtonTouched: ((UITableViewCell) -> Void)? = nil

    
    @IBOutlet var cellContainerView: UIView!
    @IBOutlet var checkboxButton: UIButton!
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var subLabel: UILabel!
    @IBOutlet var disclosureImage: UIImageView!
    @IBOutlet var alertTypeImageView: UIImageView!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var iconOneToOneConstraint: NSLayoutConstraint!
    @IBOutlet var iconWidthZeroConstraint: NSLayoutConstraint!
    @IBOutlet var iconSpacerWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellContainerView.layer.cornerRadius = 10
        self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func resetCell() {
        mainLabel.text = ""
        subLabel.text = "No alert set"
        checkboxButton.isSelected = false
        setIconType(.none)
    }
    

    // when checkBoxButton is pressed, toggle the selected state of the button
    @IBAction func onCheckBox(_ sender: Any) {
        checkboxButton.isSelected = !checkboxButton.isSelected
        onButtonTouched?(self)
    }
}

extension ReminderCell {
    
    enum IconType: String {
        case none
        case alertEnteringLocation
        case alertLeavingLocation
        case alertCalendar
    }
    
    func setIconType(_ type: IconType) {
        
            switch type {
            
            case .none:
                showIcon(false)
                iconImageView.image = UIImage()
                
            case .alertEnteringLocation, .alertLeavingLocation, .alertCalendar:
                showIcon(true)
                iconImageView.image = UIImage(named: type.rawValue)
            }
    }
    
    private func showIcon(_ iconOn: Bool) {
        
        if iconOn {
            
            // the order of these constraint changes matter in preventing broken constraints
            iconWidthZeroConstraint.isActive = false
            iconOneToOneConstraint.isActive = true
            iconSpacerWidthConstraint.constant = 8
            
            
        } else {
            
            // the order of these constraint changes matter in preventing broken constraints
            iconOneToOneConstraint.isActive = false
            iconSpacerWidthConstraint.constant = 0
            iconWidthZeroConstraint.isActive = true
        }
    }
}

extension ReminderCell {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        cellContainerView.backgroundColor = UIColor.lightGray
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cellContainerView.backgroundColor = UIColor.white
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cellContainerView.backgroundColor = UIColor.white
        super.touchesCancelled(touches, with: event)
    }
}
