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
    @IBOutlet var alertDateCell: UITableViewCell!
    @IBOutlet var notifyAtLocationLabel: UILabel!
    
    var pickingDate: Bool = false
    var triggerWhenLeaving: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertDateDoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left

        // this hindered the cell selection touch handling, so went with just the "done" button on the keyboard
//        // so we can cancel out of text editing
//        let tap = UITapGestureRecognizer(target: self, action: #selector(ReminderViewController.onTap))
//        view.addGestureRecognizer(tap)
        
        reminderNameTextField.delegate = self
        
        // make sure alert stuff is off if the reminder has been completed
        if let reminder = reminder, reminder.completed {
            reminder.triggerDate = nil
            reminder.shouldTriggerOnLocation = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // when leaving the screen save stuff and refresh the notifications
        
        if let text = reminderNameTextField.text {
            
            reminder?.name = text
            CoreDataController.shared.saveContext()
        }
        
        if let reminder = reminder {
            
            // call this just to make sure when we leave the screen the notification is accurate
            NotificationManager.shared.refreshCalendarNotification(reminder: reminder)
            NotificationManager.shared.refreshLocationNotification(reminder: reminder)
        }

        NotificationManager.shared.listAllPendingNotificationRequests()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // using this method to collapse and show different elements based on state
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let reminder = reminder else { return RowIdentity.hiddenRowHeight }
        
        if let rowIdentity = RowIdentity(indexPath: indexPath) {
            
            switch rowIdentity {
            
            case .alertDateDescription:
                
                if reminder.triggerDate != nil {
                    
                    return RowIdentity.standardRowHeight
                    
                } else {
                    
                    return RowIdentity.hiddenRowHeight
                }
                
            case .alertDateOrDatePicker:
             
                if reminder.triggerDate != nil {
                    
                    if pickingDate {
                        return RowIdentity.datePickerRowHeight
                    } else {
                        return RowIdentity.hiddenRowHeight
                    }
                    
                } else {
                    
                    return RowIdentity.hiddenRowHeight
                }
                
                
                
            case .alertLocation:
                
                if reminder.shouldTriggerOnLocation {
                    
                    return RowIdentity.standardRowHeight
                    
                } else {
                    
                    return RowIdentity.hiddenRowHeight
                }
                
            case .list, .notes:
                return RowIdentity.hiddenRowHeight
                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LocationViewController {
            vc.delegate = self
        }
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
            
        } else {
            
            alertAtLocationSwitch.setOn(false, animated: false)
        }
        
        refreshLocation()

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
        
        alertDatePicker.isHidden = true
        
        alertDateCell.layoutIfNeeded()
        
        pickingDate = false
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func showDatePickerStuff() {
        
        // set the picker's date to the current triggerDate
        // if this is less than the minimum date, then it will be automatically changed to the earliest possible date
        if let reminder = reminder, let triggerDate = reminder.triggerDate {
            
            alertDatePicker.date = triggerDate as Date
        }
        
        alertDatePicker.isHidden = false
        
        alertDateCell.layoutIfNeeded()

        pickingDate = true

        alertDatePicker.minimumDate = Date() + 60 * 1
        
        // if reminder date is in the past
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
        
        if alertAtLocationSwitch.isOn,
           let reminder = reminder,
           let location = reminder.triggerLocation,
           location.isLocationSet {
            
            if location.triggerWhenLeaving {
                notifyAtLocationLabel.text = "Notify me when I leave..."
            } else {
                notifyAtLocationLabel.text = "Notify me when I arrive at..."
            }
            
            self.alertLocationLabel.text = location.prettyLocationDescription

        } else {
            
            notifyAtLocationLabel.text = "Notify me at a location"
            alertLocationLabel.text = "Location not set"
        }
    }
    
    enum SwitchSource {
        case calendar
        case location
    }
    
    func showCompletedWarning(source: SwitchSource, sender: UISwitch) {

        let alert = UIAlertController(title: "Already Completed", message: "This reminder was marked as complete. Do you want to reactivate it?", preferredStyle: .alert)
        
        let reactivate = UIAlertAction(title: "Yes, mark as incomplete", style: .default) { (action) in
            self.reminder?.completed = false
            CoreDataController.shared.saveContext()
            
            switch source {
            
            case .calendar:
                sender.setOn(true, animated: true)
                self.onAlertDateSwitch(sender)
                
            case .location:
                sender.setOn(true, animated: true)
                self.onAlertLocationSwitch(sender)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(reactivate)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
    
    func releaseTextField() {
        
        if reminderNameTextField.isFirstResponder {
            reminderNameTextField.resignFirstResponder()
            
            if let reminder = reminder, let text = reminderNameTextField.text {
                reminder.name = text
            }
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
        
        CoreDataController.shared.saveContext()
    }

    @IBAction func onDatePickerValueChanged() {
        
        guard let reminder = reminder else { return }
        
        alertDateDoneButton.setTitle(alertDatePicker.date.prettyDateStringEEEE_MMM_d_yyyy_h_mm_a, for: .normal)
        reminder.triggerDate = alertDatePicker.date as NSDate
        CoreDataController.shared.saveContext()
    }
    
    @IBAction func onAlertDateDone() {
        
        guard let reminder = reminder else { return }
        
        if pickingDate {
            
            // if we are currently picking a date then this button is being used to dismiss the picker
            
            makeAlertDateButtonLookInactive()
            
            // update the store
            reminder.triggerDate = alertDatePicker.date as NSDate
            CoreDataController.shared.saveContext()
            
            hideDatePickerStuff()

            NotificationManager.shared.refreshCalendarNotification(reminder: reminder)
            
        } else {
            
            // if we are not currently picking a date, then the user wants to change the date
            
            makeAlertDateButtonLookActive()
            
            showDatePickerStuff()
        }
    }
    
    @IBAction func onAlertDateSwitch(_ sender: UISwitch) {
        
        // request notification authorization when creating reminders
        NotificationManager.shared.requestAuthorization()
        
        guard let reminder = reminder else { return }
        
        guard !reminder.completed else {
            sender.setOn(false, animated: true)
            showCompletedWarning(source: .calendar, sender: sender)
            return
        }
        
        // this switch toggles whether there will be an alert based on date/time
        
        if let _ = reminder.triggerDate {
            
            // if there is currently a trigger date set then we are turning it off
            
            // clear it out and save to store
            reminder.triggerDate = nil
            
            hideDatePickerStuff()
            
        } else {
            
            // there is no trigger date, so we are setting it now
            
            // set trigger date to a default alert date/time and save it to store
            let defaultDate = Date() + 60*60 // default to one hour in the future
            reminder.triggerDate = defaultDate as NSDate
            
            makeAlertDateButtonLookActive()
            
            showDatePickerStuff()
        }

        CoreDataController.shared.saveContext()

        // create/update/delete the notification
        NotificationManager.shared.refreshCalendarNotification(reminder: reminder)
    }
    
    @IBAction func onAlertLocationSwitch(_ sender: UISwitch) {
        
        // request notification authorization when creating reminders
        NotificationManager.shared.requestAuthorization()
        
        guard let reminder = reminder else { return }
        
        guard !reminder.completed else {
            sender.setOn(false, animated: true)
            showCompletedWarning(source: .location, sender: sender)
            return
        }
        
        if reminder.shouldTriggerOnLocation {
            
            // if shouldTriggerOnLocation is on then we are turning it off
            
            // clear it out and save to store
            reminder.shouldTriggerOnLocation = false
            
        } else {
            
            // there is no trigger location, so we are setting it now
            
            // if no triggerLocation has ever been created then create it now
            if reminder.triggerLocation == nil {
                
                let location = TriggerLocation.newInstance(context: CoreDataController.shared.managedObjectContext)
                reminder.triggerLocation = location
            }

            reminder.shouldTriggerOnLocation = true
        }

        CoreDataController.shared.saveContext()
        
        NotificationManager.shared.refreshLocationNotification(reminder: reminder)
        refreshLocation()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}




// MARK - LocationViewControllerDelegate
extension ReminderViewController: LocationViewControllerDelegate {
    
    func onLocationPicked(latitude: Double, longitude: Double, triggerWhenLeaving: Bool, locationName: String?, addressDescription: String?, range: Int) {

        guard let reminder = reminder else { return }
        
        let locationToWorkOn: TriggerLocation
        
        // if no triggerLocation has ever been created then create it now
        if let triggerLocation = reminder.triggerLocation {
            
            locationToWorkOn = triggerLocation
            
        } else {
            let location = TriggerLocation.newInstance(context: CoreDataController.shared.managedObjectContext)
            
            reminder.triggerLocation = location
            
            locationToWorkOn = location
            
            // initial value
            // this is a bit fiddly - since we are using a delegate, when a TriggerLocation is first created, the triggerWhenLeaving should be defaulted to false and the GUI segmented controller should be changed to match
            // if it is just an update then we allow the getTrigger and setTrigger methods to change those values
            locationToWorkOn.triggerWhenLeaving = triggerWhenLeaving
        }

        locationToWorkOn.latitude = latitude
        locationToWorkOn.longitude = longitude
        locationToWorkOn.name = locationName
        locationToWorkOn.addressDescription = addressDescription
        locationToWorkOn.range = Int16(range)

        CoreDataController.shared.saveContext()
        
        // create/update notification
        NotificationManager.shared.refreshLocationNotification(reminder: reminder)
        
        // update the label to show location description
        refreshLocation()
    }
    
    func setTriggerWhenLeaving(whenLeaving: Bool) {
        
        guard let reminder = reminder, let location = reminder.triggerLocation else { return }
        
        location.triggerWhenLeaving = whenLeaving
        CoreDataController.shared.saveContext()
    }
    
    func setRange(range: Int) {
        
        guard let reminder = reminder, let location = reminder.triggerLocation else { return }
        
        location.range = Int16(range)
        CoreDataController.shared.saveContext()
    }
    
    func currentTriggerLocation() -> TriggerLocation? {
        
        guard let reminder = reminder, let location = reminder.triggerLocation, location.isLocationSet else { return nil }
        
        return location
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

extension ReminderViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        releaseTextField()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        releaseTextField()
        return false
    }
}

