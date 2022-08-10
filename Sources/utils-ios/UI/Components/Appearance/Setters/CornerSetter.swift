//
//  CornerRadiusSetter.swift
//  
//
//  Created by Miroslav Yozov on 27.07.22.
//

import UIKit

@objc
public protocol UtilsUICornerSetter {
    dynamic func set(cornerRadius radius: CGFloat)
}

extension UtilsUICornerSetter {
    public func set(cornerRadius radius: Utils.UI.CornerRadiusPreset) {
        set(cornerRadius: radius.value)
    }
}

extension CALayer: UtilsUICornerSetter {
    public func set(cornerRadius radius: CGFloat) {
        self.cornerRadius = radius
        self.masksToBounds = true
    }
}

extension UIView: UtilsUICornerSetter {
    public func set(cornerRadius radius: CGFloat) {
        self.layer.set(cornerRadius: radius)
    }
}
