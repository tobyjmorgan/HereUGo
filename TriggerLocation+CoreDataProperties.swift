//
//  TriggerLocation+CoreDataProperties.swift
//  HereUGo
//
//  Created by redBred LLC on 2/7/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData


extension TriggerLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TriggerLocation> {
        return NSFetchRequest<TriggerLocation>(entityName: "TriggerLocation");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var triggerWhenLeaving: Bool
    @NSManaged public var range: Int16
    @NSManaged public var reminder: Reminder?

}
