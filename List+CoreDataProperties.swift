//
//  List+CoreDataProperties.swift
//  HereUGo
//
//  Created by redBred LLC on 2/7/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List");
    }

    @NSManaged public var name: String?
    @NSManaged public var reminders: NSSet?

}

// MARK: Generated accessors for reminders
extension List {

    @objc(addRemindersObject:)
    @NSManaged public func addToReminders(_ value: Reminder)

    @objc(removeRemindersObject:)
    @NSManaged public func removeFromReminders(_ value: Reminder)

    @objc(addReminders:)
    @NSManaged public func addToReminders(_ values: NSSet)

    @objc(removeReminders:)
    @NSManaged public func removeFromReminders(_ values: NSSet)

}
