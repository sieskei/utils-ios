//
//  UIApplication+.swift
//  
//
//  Created by Miroslav Yozov on 15.05.23.
//

import UIKit

extension UIApplication {
    private static let notificationSettingsURLString: String = {
        if #available(iOS 16, *) {
            return UIApplication.openNotificationSettingsURLString
        }

        if #available(iOS 15.4, *) {
            return UIApplicationOpenNotificationSettingsURLString
        }

        if #available(iOS 8.0, *) {
            // just opens settings
            return UIApplication.openSettingsURLString
        }

        // lol bruh
        return ""
    }()

    private static let appNotificationSettingsURL: URL? = .init(string: notificationSettingsURLString)

    public func openAppNotificationSettings() {
        if let url = UIApplication.appNotificationSettingsURL, canOpenURL(url) {
            open(url)
        }
    }
}
