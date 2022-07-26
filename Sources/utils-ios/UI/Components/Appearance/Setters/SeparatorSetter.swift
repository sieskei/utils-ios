//
//  SeparatorSetter.swift
//  
//
//  Created by Miroslav Yozov on 26.07.22.
//

import UIKit

@objc
public protocol SeparatorSetter {
    dynamic func set(separatorColor color: UIColor)
}

extension UIView: SeparatorSetter {
    public func set(separatorColor color: UIColor) {
        self.separatorColor = color
    }
}
