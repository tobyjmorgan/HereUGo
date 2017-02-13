//
//  ReminderListViewController.swift
//  HereUGo
//
//  Created by redBred LLC on 2/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class ReminderListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var sortOptionsContainerView: UIView!
    @IBOutlet var sortButtons: [UIButton]!
    
    var detailViewController: ReminderViewController? = nil

    var lastReminder: Reminder? = nil
    
    // our core data singleton
    let dataController = CoreDataController.shared
    
    // will handle fetching core data results
    lazy var fetchedResultsManager: ReminderFetchedResultsManager = {
        
        let manager = ReminderFetchedResultsManager(managedObjectContext: self.dataController.managedObjectContext, tableView: self.tableView, onUpdateCell: self.configureCell)
        
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        //searchBar.layer.cornerRadius = 10

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ReminderViewController
        }

        // listen for errors
        NotificationCenter.default.addObserver(self, selector: #selector(ReminderListViewController.onDailyDiaryError(notification:)), name: TJMApplicationError.ErrorNotification, object: nil)

        //sortOptionsContainerView.layer.cornerRadius = 10
        refreshView()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        //        tableView.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        
        // unselect anything that was previously selected when returning to this screen
        // but only if not in split view mode (both sides showing)
        if self.splitViewController!.isCollapsed {
            
            if let selections = tableView.indexPathsForSelectedRows {
                
                for selection in selections {
                    tableView.deselectRow(at: selection, animated: true)
                }
            }
        }
        
        lastReminder = nil
        
        tableView.reloadData()
        
        displayWelcome()
        
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            if let lastReminder = lastReminder {
                let controller = (segue.destination as! UINavigationController).topViewController as! ReminderViewController
                controller.reminder = lastReminder
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

// MARK: Helper methods
extension ReminderListViewController {
    
    static let beenRunBeforeKey = "BeenRunBefore"
    
    func displayWelcome() {
        
        let defaults = UserDefaults.standard
        
        let beenRunBefore = defaults.bool(forKey: ReminderListViewController.beenRunBeforeKey)
        
        if !beenRunBefore {
            
            let alert = UIAlertController(title: "Welcome", message: "To add a reminder, just click the Add button in the top right. Enjoy!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Will do!", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            defaults.set(true, forKey: ReminderListViewController.beenRunBeforeKey)
            defaults.synchronize()
        }
    }
    
    func insertNewObject(_ sender: Any) {
        
        // clear out any search text so the new row will appear
        searchBar.text = ""
        fetchedResultsManager.searchString = ""
        
        // create new row
        let newReminder = Reminder.newInstance(context: dataController.managedObjectContext)        
        dataController.saveContext()
        
        // automatically go to detail view to edit details
        lastReminder = newReminder
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // configure the cell to represent the information in the row
    func configureCell(_ cell: UITableViewCell, withEntry entry: Reminder) {
        
        guard let reminderCell = cell as? ReminderCell else { return }
        
        reminderCell.subLabel.text = (entry.createDate as Date).prettyDateStringEEE_M_d_yy_h_mm_a
        reminderCell.mainLabel!.text = entry.name
        
        reminderCell.layoutIfNeeded()
    }

    func refreshView() {
        
        refreshSortButtons()
    }

    func refreshSortButtons() {
        
        // keep track of the user's preference on how results are sorted
        let sortPreference = UserSettings.getSortPreference()
        
        for sortButton in sortButtons {
            sortButton.setTitleColor(UIColor.lightGray, for: .normal)
            
            if sortButton.tag == sortPreference.rawValue {
                sortButton.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
}



// MARK: - IBActions
extension ReminderListViewController {
    
    @IBAction func onSortButton(_ sender: UIButton) {
        guard let sortPreference = SortPreference(rawValue: sender.tag) else { return }
        
        UserSettings.setSortPreference(sortPreference: sortPreference)
        refreshSortButtons()
        fetchedResultsManager.resetFetchedResultsController()
    }
}



// MARK: - Table View
extension ReminderListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = fetchedResultsManager.fetchedResultsController.sections?.count ?? 0
        
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsManager.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        
        cell.resetCell()
        
        let entry = fetchedResultsManager.fetchedResultsController.object(at: indexPath)
        
        configureCell(cell, withEntry: entry)
        
        // ensure the cell's layout is updated
        cell.layoutIfNeeded()
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        
//        if let sections = fetchedResultsManager.fetchedResultsController.sections {
//            
//            let currentSection = sections[section]
//            let prettySectionName = DiaryEntry.prettySectionIdentifier(sectionIdentifier: currentSection.name)
//            
//            return prettySectionName
//        }
//        
//        return nil
//    }
//    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsManager.fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsManager.fetchedResultsController.object(at: indexPath))
            
            dataController.saveContext()
        }
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        lastReminder = fetchedResultsManager.fetchedResultsController.object(at: indexPath)
        
        return indexPath
    }
}



// MARK: UISearchBarDelegate
extension ReminderListViewController: UISearchBarDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.showsCancelButton = true
        
        fetchedResultsManager.searchString = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        fetchedResultsManager.searchString = ""
        
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
}






