//
//  TJMApplicationError.swift
//  DailyDiary
//
//  Created by redBred LLC on 2/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

struct TJMApplicationError {
    static let ErrorNotification = Notification.Name("TJMApplicationError")
    static let ErrorKey = "ErrorKey"
    
    let title: String
    let message: String
    let fatal: Bool
    
    func makeUserInfoDict() -> [String : Any] {
        return [TJMApplicationError.ErrorKey : TJMApplicationError(title: title, message: message, fatal: fatal)]
    }
    
    static func getErrorFromNotification(notification: Notification) -> TJMApplicationError? {
    
        guard let userInfo = notification.userInfo as? [String: Any],
              let error = userInfo[TJMApplicationError.ErrorKey] as? TJMApplicationError else { return nil }
        
        return error
    }
}
