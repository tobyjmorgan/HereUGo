//
//  ReminderViewController.swift
//  HereUGo
//
//  Created by redBred LLC on 2/8/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class ReminderViewController: UITableViewController {

    var reminder: Reminder?
    
    @IBOutlet var reminderNameTextField: UITextField!
    @IBOutlet var alertAtDateAndTimeSwitch: UISwitch!
    @IBOutlet var alertDatePicker: UIDatePicker!
    @IBOutlet var alertDateDoneButton: UIButton!
    @IBOutlet var alertAtLocationSwitch: UISwitch!
    @IBOutlet var alertLocationLabel: UILabel!
    @IBOutlet var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet var listNameLabel: UILabel!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var datePickerContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var alertDateCell: UITableViewCell!
    
    var pickingDate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertDateDoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let text = reminderNameTextField.text {
            
            reminder?.name = text
            CoreDataController.sharedInstance.saveContext()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let rowIdentity = RowIdentity(indexPath: indexPath) {
            
            switch rowIdentity {
            
            case .alertDateDescription:
                
                if reminder?.triggerDate != nil {
                    
                    return RowIdentity.standardRowHeight
                    
                } else {
                    
                    return RowIdentity.hiddenRowHeight
                }
                
            case .alertDateOrDatePicker:
             
                if reminder?.triggerDate != nil {
                    
                    if pickingDate {
                        return RowIdentity.datePickerRowHeight
                    } else {
                        return RowIdentity.hiddenRowHeight
                    }
                    
                } else {
                    
                    return RowIdentity.hiddenRowHeight
                }
                
                
                
            case .alertLocation:
                
                if let reminder = reminder,
                    reminder.shouldTriggerOnLocation {
                    
                    return RowIdentity.standardRowHeight
                    
                } else {
                    
                    return RowIdentity.hiddenRowHeight
                }
                
            default:
                break
            }
        }
        
        return RowIdentity.standardRowHeight
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let rowIdentity = RowIdentity(indexPath: indexPath) {
            
            if rowIdentity.selectable {
                return indexPath
            } else {
                return nil
            }
        }
        
        return indexPath
    }
}



// MARK: - Helper Methods
extension ReminderViewController {
    
    func refreshView() {
        
        guard let reminder = reminder, let reminderNameTextField = reminderNameTextField else { return }
        
        reminderNameTextField.text = reminder.name
        
        alertDatePicker.isHidden = true
        
        if let _ = reminder.triggerDate {
            
            alertAtDateAndTimeSwitch.setOn(true, animated: false)
            makeAlertDateButtonLookInactive()
            
        } else {

            alertAtDateAndTimeSwitch.setOn(false, animated: false)
        }
        
        if reminder.shouldTriggerOnLocation {
            
            alertAtLocationSwitch.setOn(true, animated: false)
            
            refreshLocation()
            
        } else {
            
            alertAtLocationSwitch.setOn(false, animated: false)
            alertLocationLabel.text = ""
        }
        
        if reminder.highPriority {
            prioritySegmentedControl.selectedSegmentIndex = 1
        } else {
            prioritySegmentedControl.selectedSegmentIndex = 0
        }
        
        
        // make sure all visible cells are refreshed
        if let allVisibleIndexPaths = self.tableView.indexPathsForVisibleRows {
            
            for indexPath in allVisibleIndexPaths {
                
                if let cell = self.tableView.cellForRow(at: indexPath) {
                    
                    cell.layoutIfNeeded()
                }
            }
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()

    }
    
    func hideDatePickerStuff() {
        
        datePickerContainerHeightConstraint.constant = 44
        
        alertDatePicker.isHidden = true
        
        alertDateCell.layoutIfNeeded()
        
        pickingDate = false
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func showDatePickerStuff() {
        
        datePickerContainerHeightConstraint.constant = 216
        
        alertDatePicker.isHidden = false
        
        alertDateCell.layoutIfNeeded()

        pickingDate = true

        alertDatePicker.minimumDate = Date() + 60 * 10
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func makeAlertDateButtonLookActive() {
        
        if let alertDate = reminder?.triggerDate {
            
            // make the button look like a button again
            alertDateDoneButton.setTitle((alertDate as Date).prettyDateStringEEEE_MMM_d_yyyy_h_mm_a, for: .normal)
            alertDateDoneButton.setTitleColor(UIColor.blue, for: .normal)
        }
    }

    func makeAlertDateButtonLookInactive() {
        
        if let alertDate = reminder?.triggerDate {
            // make the button look like a label
            alertDateDoneButton.setTitle((alertDate as Date).prettyDateStringEEE_M_d_yy_h_mm_a, for: .normal)
            alertDateDoneButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    func refreshLocation() {
        
        if let reminder = reminder,
           let location = reminder.triggerLocation,
           location.isLocationSet {
            
            alertLocationLabel.text = "Location: \(location.latitude), \(location.longitude)"
            
        } else {
            
            alertLocationLabel.text = "Location not set"
        }
    }
}




// MARK: - IBActions
extension ReminderViewController  {
    
    @IBAction func onPriorityChanged(_ sender: UISegmentedControl) {
        
        guard let reminder = reminder else { return }
        
        if sender.selectedSegmentIndex == 0 {
            reminder.highPriority = false
        } else {
            reminder.highPriority = true
        }
        
        CoreDataController.sharedInstance.saveContext()
    }

    @IBAction func onDatePickerValueChanged() {
        
        guard let reminder = reminder else { return }
        
        alertDateDoneButton.setTitle(alertDatePicker.date.prettyDateStringEEEE_MMM_d_yyyy_h_mm_a, for: .normal)
        reminder.triggerDate = alertDatePicker.date as NSDate
        CoreDataController.sharedInstance.saveContext()
    }
    
    @IBAction func onAlertDateDone() {
        
        guard let reminder = reminder else { return }
        
        if pickingDate {
            
            // if we are currently picking a date then this button is being used to dismiss the picker
            
            makeAlertDateButtonLookInactive()
            
            // update the store
            reminder.triggerDate = alertDatePicker.date as NSDate
            CoreDataController.sharedInstance.saveContext()
            
            hideDatePickerStuff()
            
        } else {
            
            // if we are not currently picking a date, then the user wants to change the date
            
            makeAlertDateButtonLookActive()
            
            showDatePickerStuff()
        }
    }
    
    @IBAction func onAlertDateSwitch(_ sender: Any) {
        
        guard let reminder = reminder else { return }
        
        // this switch toggles whether there will be an alert based on date/time
        
        if let _ = reminder.triggerDate {
            
            // if there is currently a trigger date set then we are turning it off
            
            // clear it out and save to store
            reminder.triggerDate = nil
            CoreDataController.sharedInstance.saveContext()
            
            hideDatePickerStuff()
            
        } else {
            
            // there is no trigger date, so we are setting it now
            
            // set trigger date to a default alert date/time and save it to store
            let defaultDate = Date() + 60*10
            reminder.triggerDate = defaultDate as NSDate
            CoreDataController.sharedInstance.saveContext()
            
            makeAlertDateButtonLookActive()
            
            showDatePickerStuff()
        }
        
    }
    
    @IBAction func onAlertLocationSwitch(_ sender: Any) {
        
        guard let reminder = reminder else { return }
        
        if reminder.shouldTriggerOnLocation {
            
            // if shouldTriggerOnLocation is on then we are turning it off
            
            // clear it out and save to store
            reminder.shouldTriggerOnLocation = false
            CoreDataController.sharedInstance.saveContext()
            
        } else {
            
            // there is no trigger location, so we are setting it now
            
            // if no triggerLocation has ever been created then create it now
            if reminder.triggerLocation == nil {
                
                let location = TriggerLocation.newInstance(context: CoreDataController.sharedInstance.managedObjectContext)
                reminder.triggerLocation = location
            }

            reminder.shouldTriggerOnLocation = true
            CoreDataController.sharedInstance.saveContext()
            
            refreshLocation()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}



// MARK: - Row Identity - for collapsing / showing cells based on state
extension ReminderViewController {
    
    enum RowIdentity: Int {
        
        static let hiddenRowHeight: CGFloat = 0
        static let standardRowHeight: CGFloat = 44
        static let datePickerRowHeight: CGFloat = 217
        
        case name
        case alertDateSwitch
        case alertDateDescription
        case alertDateOrDatePicker
        case alertLocationSwitch
        case alertLocation
        case priority
        case list
        case notes
        
        init?(indexPath: IndexPath) {
            
            switch (indexPath.section, indexPath.row) {
                
            case (0,0): self = RowIdentity.name
            case (1,0): self = RowIdentity.alertDateSwitch
            case (1,1): self = RowIdentity.alertDateDescription
            case (1,2): self = RowIdentity.alertDateOrDatePicker
            case (2,0): self = RowIdentity.alertLocationSwitch
            case (2,1): self = RowIdentity.alertLocation
            case (3,0): self = RowIdentity.priority
            case (3,1): self = RowIdentity.list
            case (3,2): self = RowIdentity.notes
                
            default: return nil
            }
        }
        
        var selectable: Bool {
            switch self {
            case .alertLocation, .list: return true
            default: return false
            }
        }
    }
}