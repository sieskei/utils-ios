//
//  BackgroundSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit

@objc
public protocol UtilsUIBackgroundSetter {
    dynamic func set(backgroundColor color: UIColor)
}

extension UIView: UtilsUIBackgroundSetter {
    public func set(backgroundColor color: UIColor) {
        self.backgroundColor = color
    }
}
