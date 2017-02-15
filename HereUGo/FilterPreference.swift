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
    case incomplete = 1
    case complete
    case both
}

// get the appropriate predicate for the filter type
extension FilterPreference {
    func getPredicate() -> NSPredicate? {
        switch self {
        case .incomplete:
            return NSPredicate(format: "completed == NO")
        case .complete:
            return NSPredicate(format: "completed == YES")
        case .both:
            return nil
        }
    }
}
