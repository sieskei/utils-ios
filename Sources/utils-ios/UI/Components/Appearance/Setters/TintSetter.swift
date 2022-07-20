//
//  TintSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit

@objc
public protocol UtilsUITintSetter {
    dynamic func set(tintColor color: UIColor)
}

@objc
public protocol UtilsUITrackTintSetter {
    dynamic func set(trackTintColor color: UIColor)
}

extension UIView: UtilsUITintSetter {
    public func set(tintColor color: UIColor) {
        self.tintColor = color
    }
}

extension UIProgressView: UtilsUITrackTintSetter {
    public func set(trackTintColor color: UIColor) {
        self.trackTintColor = color
    }
}
