//
//  NotificationBar.swift
//  NotificationBar
//
//  Created by Giáp Trần on 1/8/17.
//  Copyright © 2017 Giáp Trần. All rights reserved.
//

import UIKit
import AVFoundation

public typealias SelectNotificationHandler = ((Void) -> Void)
public typealias SendNotificationHandler = ((String) -> Void)

public class NotificationBar: NSObject {
    
    // MARK: Private method
    
    public static let shared = NotificationBar()
    
    private weak var notificationView: NotificationView?
    
    public var selectHandler: SelectNotificationHandler?
    public var sendHandler: SendNotificationHandler?
    
    private var appName: String?
    private var appIcon: String?
    
    // MARK: Constructor
    
    private override init() {
        super.init()
        
        var infoDic: Dictionary = Bundle.main.infoDictionary!
        appName = infoDic["CFBundleName"] as? String
        if let _ = infoDic["CFBundleIcons"] {
            infoDic = infoDic["CFBundleIcons"] as! Dictionary
            infoDic = infoDic["CFBundlePrimaryIcon"] as! Dictionary
            
            appIcon = (infoDic["CFBundleIconFiles"] as AnyObject).object(at: 0) as? String
        }
    }
    
    // MARK: Public method
    
    public func showNotification(title: String, message: String, style: NotificationStyle = .alert) {
        if notificationView?.isExpanding != true {
            hideNotification()
            
            setUpNotificationBar(title, body: message , notificationStyle: style)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
    }
    
    public func hideNotification() {
        notificationView?.hideNotification(animated: false)
    }
    
    // MARK: Private method
    
    private func setUpNotificationBar(_ title: String, body: String, notificationStyle: NotificationStyle, timeOutDefault: Double = 3) {
        let notificationView = NotificationView(frame: CGRect.zero)
        notificationView.delegate = self
        notificationView.timeOutDefault = timeOutDefault
        notificationView.setStyle(notificationStyle, title: title, body: body)
        notificationView.setAppInfo(appName: appName, appIcon: appIcon)
        self.notificationView = notificationView
    }
    
}

// MARK: NotificationDelegate

extension NotificationBar: NotificationDelegate {
    
    func didSelectMessage() {
        selectHandler?()
    }
    
    func didSendMessage(_ text: String) {
        sendHandler?(text)
    }
    
}
