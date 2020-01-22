//
//  BackgroundSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit

@objc
public protocol BackgroundSetter {
    dynamic func set(backgroundColor color: UIColor)
}

extension UIView: BackgroundSetter {
    public func set(backgroundColor color: UIColor) {
        self.backgroundColor = color
    }
}
