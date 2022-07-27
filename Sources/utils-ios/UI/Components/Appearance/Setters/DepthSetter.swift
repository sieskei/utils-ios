//
//  UtilsUIDepthSetter.swift
//  
//
//  Created by Miroslav Yozov on 27.07.22.
//

import UIKit

@objc
public protocol UtilsUIDepthSetter {
    dynamic func set(depthOffset offset: Utils.UI.Offset, opacity: Float, radius: CGFloat)
}

extension UtilsUIDepthSetter {
    public func set(depth: Utils.UI.Depth.Preset) {
        let rawValue = depth.value.rawValue
        set(depthOffset: rawValue.0.asOffset, opacity: rawValue.1, radius: rawValue.2)
    }
}

extension CALayer: UtilsUIDepthSetter {
    public func set(depthOffset offset: Utils.UI.Offset, opacity: Float, radius: CGFloat) {
        depth = .init(offset: offset, opacity: opacity, radius: radius)
    }
}

extension UIView: UtilsUIDepthSetter {
    public func set(depthOffset offset: Utils.UI.Offset, opacity: Float, radius: CGFloat) {
        self.layer.set(depthOffset: offset, opacity: opacity, radius: radius)
    }
}
