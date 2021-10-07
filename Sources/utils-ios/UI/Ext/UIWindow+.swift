//
//  UIWindow+.swift
//  
//
//  Created by Miroslav Yozov on 6.08.20.
//

import UIKit

public extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
