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
    let onUpdateCell: (UITableViewCell, Reminder) -> Void
    
    init(managedObjectContext: NSManagedObjectContext, tableView: UITableView, onUpdateCell: @escaping (UITableViewCell, Reminder) -> Void) {
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
    
    var fetchedResultsController: NSFetchedResultsController<Reminder> {
    
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        //let sectionNameKeyPath = "sectionIdentifier"
        
        request.sortDescriptors = getSortDescriptors()

        // Set the batch size to a suitable number.
        request.fetchBatchSize = 20
        
        
        if searchString.characters.count > 0 {
            
            let predicate = NSPredicate(format: "name contains[cd] %@ OR notes contains[cd] %@", argumentArray: [searchString, searchString])
            request.predicate = predicate
            
        } else {
            
            request.predicate = nil
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
            NotificationCenter.default.post(name: TJMApplicationError.ErrorNotification, object: self, userInfo: fetchError.makeUserInfoDict())
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
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! ReminderCell
            onUpdateCell(cell, anObject as! Reminder)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
