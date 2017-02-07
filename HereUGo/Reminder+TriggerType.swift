//
//  Reminder+TriggerType.swift
//  HereUGo
//
//  Created by redBred LLC on 2/7/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

enum TriggerType: Int {
    case none = 0
    case location
    case date
    case locationOrDate
}

extension TriggerType {

    var description: String {
        switch self {
        case .none:
            return "No alerts"
        case .location:
            return "Alerted when near location"
        case .date:
            return "Alerted on due date"
        case .locationOrDate:
            return "Alerted when near location or on due date"
        }
    }
}

extension Reminder {
    
    var triggerType: TriggerType {
        get {
            if let newTriggerType = TriggerType(rawValue: Int(triggerTypeInteger)) {
                return newTriggerType
            }
            
            return .none
        }
        set {
            self.triggerTypeInteger = Int16(newValue.rawValue)
        }
    }
}
