//
//  Reminder+CoreDataProperties.swift
//  HereUGo
//
//  Created by redBred LLC on 2/7/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder");
    }

    @NSManaged public var createDate: NSDate
    @NSManaged public var name: String
    @NSManaged public var highPriority: Bool
    @NSManaged public var shouldTriggerOnLocation: Bool
    @NSManaged public var triggerDate: NSDate?
    @NSManaged public var notes: String
    @NSManaged public var completed: Bool
    @NSManaged public var triggerLocation: TriggerLocation?
    @NSManaged public var list: List?

}
