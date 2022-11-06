//
//  HeightSetter.swift
//  
//
//  Created by Miroslav Yozov on 5.11.22.
//

import UIKit

@objc
public protocol UtilsUIHeightSetter {
    dynamic func set(height value: CGFloat)
}

extension UtilsUIHeightSetter {
    public func set(heightPreset preset: Utils.UI.HeightPreset) {
        set(height: preset.value)
    }
}

extension CALayer: UtilsUIHeightSetter {
    public func set(height value: CGFloat) {
        frame.size.height = value
    }
}

extension UIView: UtilsUIHeightSetter {
    public func set(height value: CGFloat) {
        frame.size.height = value
    }
}
