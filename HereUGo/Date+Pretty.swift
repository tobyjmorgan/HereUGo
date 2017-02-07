//
//  Date+Pretty.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/27/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension Date {
    
    // Based on https://iosdevcenters.blogspot.com/2016/04/ordinal-dateformate-like-11th-21st-in.html
    var prettyDateStringEEEE_NTH_MMMM: String {
        
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: self)
        
        let formatter = DateFormatter()
        
        // get pretty month
        formatter.dateFormat = "MMMM"
        let prettyMonth = formatter.string(from: self)
        
        // get day of the week
        formatter.dateFormat = "EEEE"
        let dayOfTheWeek = formatter.string(from: self)
        
        // get day of the month
        var day  = "\(anchorComponents.day!)"
        
        // determine the ordinal
        switch (day) {
        case "1" , "21" , "31":
            day.append("st")
        case "2" , "22":
            day.append("nd")
        case "3" ,"23":
            day.append("rd")
        default:
            day.append("th")
        }
        
        return dayOfTheWeek + " " + day + " " + prettyMonth
    }
    
    var prettyDateStringMMMM_NTH_YYYY: String {
        
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: self)
        
        let formatter = DateFormatter()
        
        // get pretty month
        formatter.dateFormat = "MMMM"
        let prettyMonth = formatter.string(from: self)
        
        // get year
        formatter.dateFormat = "YYYY"
        let year = formatter.string(from: self)
        
        // get day of the month
        var day  = "\(anchorComponents.day!)"
        
        // determine the ordinal
        switch (day) {
        case "1" , "21" , "31":
            day.append("st")
        case "2" , "22":
            day.append("nd")
        case "3" ,"23":
            day.append("rd")
        default:
            day.append("th")
        }
        
        return prettyMonth + " " + day + ", " + year
    }
    
    var prettyDateStringYYYYMM: String {
        
        let formatter = DateFormatter()
        
        // get pretty month
        formatter.dateFormat = "MM"
        let prettyMonth = formatter.string(from: self)
        
        // get year
        formatter.dateFormat = "YYYY"
        let year = formatter.string(from: self)
        
        return year + prettyMonth
    }
}
