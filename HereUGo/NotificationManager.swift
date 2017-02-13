//
//  NotificationManager.swift
//  HereUGo
//
//  Created by redBred LLC on 2/13/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject {
    
    static let calendarNotification = "HereUGoCalendarNotification"
    static let locationNotification = "HereUGoLocationNotification"
    static let notificationSound = "Notification.wav"
    
    static let shared = NotificationManager()
    
    let currentCenter = UNUserNotificationCenter.current()
    
    private override init() {
        // nothing to do here, but want to make initialization private
        // to force use of the shared instance singleton
        super.init()
    }
    
    func requestAuthorization() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (authorized, error) in
        
            if !authorized {
                let appError = TJMApplicationError(title: "Notifcations Not Athorized", message: "This app requires notifications to be authorized so you can receive alerts for date based and location based reminders", fatal: true)
                
                NotificationCenter.default.post(name: TJMApplicationError.ErrorNotification, object: self, userInfo: appError.makeUserInfoDict())
            }
        }
    }
    
    func addCalendarNotification(date: Date, reminderName: String, repeats: Bool) {
        
//        currentCenter.getNotificationSettings { (settings) in
//            
//            //switch settings.
//        }
        
        let content = UNMutableNotificationContent()
        content.title = "HereUGo Notification"
        content.body = "reminderName"
        content.badge = 1
        content.sound = UNNotificationSound(named: NotificationManager.notificationSound)
        
        let dateComponents = (Date() + 20).dateComponents //date.dateComponents
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationManager.calendarNotification, content: content, trigger: trigger)
        
        currentCenter.add(request)
    }
}
