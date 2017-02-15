//
//  Date+Pretty.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/27/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension Date {
    
    var prettyDateStringEEE_M_d_yy_h_mm_a: String {
        
        let formatter = DateFormatter()
        
        // get pretty date
        formatter.dateFormat = "EEE, M/d/yy, h:mm a"
        return formatter.string(from: self)
    }
    
    var prettyDateStringEEEE_MMM_d_yyyy_h_mm_a: String {
        
        let formatter = DateFormatter()
        
        // get pretty date
        formatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return formatter.string(from: self)
    }
    
    var dateComponents: DateComponents {
        
        let calendar = Calendar.current
        return calendar.dateComponents([.second, .hour, .minute, .timeZone, .day, .month, .year], from: self)
    }
}
