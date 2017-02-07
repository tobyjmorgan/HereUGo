//
//  ReminderCell.swift
//  HereUGo
//
//  Created by redBred LLC on 2/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {

    @IBOutlet var cellContainerView: UIView!
    @IBOutlet var checkboxButton: UIButton!
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var subLabel: UILabel!
    @IBOutlet var disclosureImage: UIImageView!
    
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
        subLabel.text = ""        
    }

}
