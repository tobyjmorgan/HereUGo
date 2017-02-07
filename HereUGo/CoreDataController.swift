//
//  CoreDataController.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/26/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController: NSObject {
    
    // singleton instance
    static let sharedInstance = CoreDataController()

    private override init() {
        // nothing to do here, but want to make initialization private
        // to force use of the shared instance singleton
        super.init()
    }

    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "HereUGo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                let nsError = error as NSError
                
                let message = "Failed set up persistent store: \(nsError.localizedDescription)"
                print(message)
                
                // post a notification for anyone listening for Core Data errors
                let coreDataError = TJMApplicationError(title: "Core Data Error", message: message, fatal: true)
                NotificationCenter.default.post(name: TJMApplicationError.ErrorNotification, object: self, userInfo: coreDataError.makeUserInfoDict())
            }
        })
        
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()

    func saveContext () {
        
        if managedObjectContext.hasChanges {
            
            do {
                
                try managedObjectContext.save()
                
            } catch {
                
                let nsError = error as NSError
                let message = "Failed to save changes: \(nsError.localizedDescription)"
                print(message)
                
                let errorUserInfo = nsError.userInfo
                print(errorUserInfo)
                
                // post a notification for anyone interested in error messages for failed save requests
                let coreDataError = TJMApplicationError(title: "Core Data Error", message: message, fatal: true)
                NotificationCenter.default.post(name: TJMApplicationError.ErrorNotification, object: self, userInfo: coreDataError.makeUserInfoDict())
            }
        }
    }
    
}
