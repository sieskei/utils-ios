//
//  DividerSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit
import Material

@objc
public protocol DividerSetter {
    dynamic func set(dividerColor color: UIColor)
}

extension UIView: DividerSetter {
    public func set(dividerColor color: UIColor) {
        self.dividerColor = color
    }
}
