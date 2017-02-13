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
    
    static let notificationSound = "Notification"
    
    static let shared = NotificationManager()
    
    let currentCenter = UNUserNotificationCenter.current()
    
    private override init() {
        // nothing to do here, but want to make initialization private
        // to force use of the shared instance singleton
        super.init()
        
        currentCenter.delegate = self
    }
    
    func requestAuthorization() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (authorized, error) in
        
            if !authorized {
                let appError = TJMApplicationError(title: "Notifcations Not Athorized", message: "This app requires notifications to be authorized so you can receive alerts for date based and location based reminders", fatal: true)
                
                NotificationCenter.default.post(name: TJMApplicationError.ErrorNotification, object: self, userInfo: appError.makeUserInfoDict())
            }
        }
    }
    
    func addCalendarNotification(date: Date, reminderName: String, identifier: String, repeats: Bool) {
        
        let content = UNMutableNotificationContent()
        content.title = reminderName
        content.body = date.prettyDateStringEEEE_MMM_d_yyyy_h_mm_a
        content.badge = 1
        content.sound = UNNotificationSound(named: NotificationManager.notificationSound)
        
        // TODO: five seconds in the future - just for testing
        // TODO: replace with commented code for release
        let dateComponents = (Date() + 5).dateComponents //date.dateComponents
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        currentCenter.add(request)
    }
    
    func removeNotification(identifier: String) {
        
        currentCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}



////////////////////////////////////////////////////////////////////////
// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let objectIDDescription = response.notification.request.identifier
        
        print("Received response to: \(objectIDDescription)")
        
        completionHandler()
    }
}
