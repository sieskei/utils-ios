//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 4.08.21.
//

import UIKit

fileprivate var WindowKey: UInt8 = 0

public protocol WindowPresentCompatible {
    var window: UIWindow { get }
    var windowLevel: UIWindow.Level { get }
    
    func windowPresent(animated: Bool, completion: (() -> Void)?)
}

public extension WindowPresentCompatible {
    var window: UIWindow {
        Utils.AssociatedObject.get(base: self, key: &WindowKey) {
            let window: UIWindow = .init()
            window.windowLevel = windowLevel
            return window
        }
    }
    
    var windowLevel: UIWindow.Level {
        .normal
    }
}

public extension WindowPresentCompatible where Self: UIViewController {
    func windowPresent(animated: Bool, completion: (() -> Void)? = nil) {
        window.rootViewController = self
        window.makeKeyAndVisible()
    }
}
