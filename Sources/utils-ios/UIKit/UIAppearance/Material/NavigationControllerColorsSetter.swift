//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 20.01.21.
//

import UIKit
import Material

@objc
public protocol NavigationControllerColorsSetter {
    dynamic func set(barBackgroundColor color: UIColor)
    dynamic func set(barBackgroundColorByNavigationItem default: UIColor)
}

extension NavigationController: NavigationControllerColorsSetter {
    public func set(barBackgroundColor color: UIColor) {
        self.barBackgroundColorSource = .color(color)
    }
    
    public func set(barBackgroundColorByNavigationItem color: UIColor) {
        self.barBackgroundColorSource = .navigationItem(default: color)
    }
}
