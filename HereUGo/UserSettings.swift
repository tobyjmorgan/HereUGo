//
//  UserSettings.swift
//  HereUGo
//
//  Created by redBred LLC on 2/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

struct UserSettings {
    
    static let sortPreferenceKey = "sortPreferenceKey"
    
    static func getSortPreference() -> SortPreference {
        
        let defaults = UserDefaults.standard
        
        guard let preference = SortPreference(rawValue: defaults.integer(forKey: UserSettings.sortPreferenceKey)) else {
            
            setSortPreference(sortPreference: .newest)
            return SortPreference.newest
        }
        
        return preference
    }
    
    static func setSortPreference(sortPreference: SortPreference) {
        
        let defaults = UserDefaults.standard
        
        defaults.set(sortPreference.rawValue, forKey: UserSettings.sortPreferenceKey)
        defaults.synchronize()
    }
}
