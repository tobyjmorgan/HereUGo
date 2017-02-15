//
//  FilterPreference.swift
//  HereUGo
//
//  Created by redBred LLC on 2/14/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData

// currently available filter preferences
enum FilterPreference: Int {
    case all = 1
    case open
    case closed
}

// get the appropriate predicate for the filter type
extension FilterPreference {
    func getPredicate() -> NSPredicate? {
        switch self {
        case .all:
            return nil
        case .open:
            return NSPredicate(format: "completed == NO")
        case .closed:
            return NSPredicate(format: "completed == YES")
        }
    }
}
