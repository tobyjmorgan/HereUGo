//
//  Reminder+Extensions.swift
//  HereUGo
//
//  Created by redBred LLC on 2/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData

extension Reminder {
    
    class func newInstance(context: NSManagedObjectContext) -> Reminder {
        
        let newInstance = Reminder(context: context)

        newInstance.createDate = Date() as NSDate
        newInstance.name = "New Reminder"
        newInstance.notes = ""
        
        return newInstance
    }
}
