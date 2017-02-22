//
//  ReminderFetchedResultsManager.swift
//  DailyDiary
//
//  Created by redBred LLC on 2/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// manages the fetched results controller for reminders
class ReminderFetchedResultsManager: NSObject, NSFetchedResultsControllerDelegate {
    
    // any search text to be used in the fetch request
    var searchString: String = "" {
        didSet {
            resetFetchedResultsController()
        }
    }
    
    // dependency injection
    let tableView: UITableView
    let managedObjectContext: NSManagedObjectContext
    let onUpdateCell: (ReminderCell, Reminder) -> Void
    
    init(managedObjectContext: NSManagedObjectContext, tableView: UITableView, onUpdateCell: @escaping (ReminderCell, Reminder) -> Void) {
        self.managedObjectContext = managedObjectContext
        self.tableView = tableView
        self.onUpdateCell = onUpdateCell
        
        super.init()
    }
    
    private var _fetchedResultsController: NSFetchedResultsController<Reminder>? = nil
    
    func resetFetchedResultsController() {

        // reset fetchedResultsController
        _fetchedResultsController = nil
        
        // reload the table view
        tableView.reloadData()
    }
    
    func getSortDescriptors() -> [NSSortDescriptor]? {
        
        let preference = UserSettings.getSortPreference()
            
        return preference.getSortDescriptors()
    }
    
    func getBaseFilterPredicate() -> NSPredicate? {
        
        let preference = UserSettings.getFilterPreference()
        
        return preference.getPredicate()
    }
    
    var fetchedResultsController: NSFetchedResultsController<Reminder> {
    
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        
        request.sortDescriptors = getSortDescriptors()

        // Set the batch size to a suitable number.
        request.fetchBatchSize = 20

        if searchString.characters.count > 0 {
            
            // the user is searching

            let predicate = NSPredicate(format: "name contains[cd] %@ OR notes contains[cd] %@", argumentArray: [searchString, searchString])
            
            if let basePredicate = getBaseFilterPredicate() {
                
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, predicate])
                
            } else {
                
                request.predicate = predicate
            }
            
            
        } else {
            
            // not searching, so just use the base predicate based on filter preference
            request.predicate = getBaseFilterPredicate()
        }
        
        
        let frc: NSFetchedResultsController<Reminder> = NSFetchedResultsController(fetchRequest: request,
                                                                                     managedObjectContext: managedObjectContext,
                                                                                     sectionNameKeyPath: nil,//sectionNameKeyPath,
                                                                                     cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            let nsError = error as NSError
            let message = "Failed to fetch data: \(nsError.localizedDescription)"
            print(message)
            
            let errorUserInfo = nsError.userInfo
            print(errorUserInfo)
            
            // post a notification for anyone interested in error messages for failed save requests
            let fetchError = TJMApplicationError(title: "Fetched Results Error", message: message, fatal: false)
            fetchError.postMyself()
        }
        
        _fetchedResultsController = frc
        
        return _fetchedResultsController!
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! ReminderCell
            onUpdateCell(cell, anObject as! Reminder)

        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
