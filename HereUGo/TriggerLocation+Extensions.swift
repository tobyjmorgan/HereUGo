//
//  TriggerLocation+Extensions.swift
//  HereUGo
//
//  Created by redBred LLC on 2/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData

extension TriggerLocation {
    
    static let fakeLatitude: Double = 100
    static let fakeLongitude: Double = 200
    
    var isLocationSet: Bool {
        return (self.latitude >= -180 && self.latitude <= 180 && self.longitude >= -90 && self.longitude <= 90)
    }
    
    class func newInstance(context: NSManagedObjectContext) -> TriggerLocation {
        
        let newInstance = TriggerLocation(context: context)
        
        newInstance.latitude = fakeLatitude
        newInstance.longitude = fakeLongitude
        newInstance.range = 50
        newInstance.triggerWhenLeaving = false
        
        return newInstance
    }
    
    var prettyLocationDescription: String {
        
        let prefix: String
        
        if self.triggerWhenLeaving {
            prefix = "<< "
        } else {
            prefix = ">> "
        }
        
        // flatmap to remove optionals
        let placeDescriptionElements: [String] = [self.name, self.addressDescription].flatMap { $0 }
        
        // concatenate with commas
        return prefix + placeDescriptionElements.joined(separator: ", ")
    }
}
