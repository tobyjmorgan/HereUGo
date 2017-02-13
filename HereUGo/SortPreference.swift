//
//  SortPreference.swift
//  HereUGo
//
//  Created by redBred LLC on 2/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData

enum SortPreference: Int {
    case closest = 1
    case newest
    case oldest
}

extension SortPreference {
    func getSortDescriptors() -> [NSSortDescriptor] {
        switch self {
        case .closest:
            return [] //NSSortDescriptor(key: "", ascending: true)
        case .newest:
            return [NSSortDescriptor(key: "createDate", ascending: false)]
        case .oldest:
            return [NSSortDescriptor(key: "createDate", ascending: true)]
        }
    }
}
