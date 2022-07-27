//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 27.07.22.
//

import UIKit

@objc
public protocol UtilsUIBorderSetter {
    dynamic func set(borderColor color: UIColor)
    dynamic func set(borderWidth width: CGFloat)
}

extension UtilsUIBorderSetter {
    public func set(borderWidthPreset width: Utils.UI.BorderWidthPreset) {
        set(borderWidth: width.value)
    }
}

extension CALayer: UtilsUIBorderSetter {
    public func set(borderColor color: UIColor) {
        self.borderColor = color.cgColor
    }
    
    public func set(borderWidth width: CGFloat) {
        self.borderWidth = width
    }
}

extension UIView: UtilsUIBorderSetter {
    public func set(borderColor color: UIColor) {
        self.layer.set(borderColor: color)
    }
    
    public func set(borderWidth width: CGFloat) {
        self.layer.set(borderWidth: width)
    }
}

