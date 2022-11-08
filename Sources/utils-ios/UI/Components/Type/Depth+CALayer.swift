//
//  CALayer+Depth.swift
//  
//
//  Created by Miroslav Yozov on 27.07.22.
//

import UIKit

fileprivate var DepthKey: UInt8 = 0

extension CALayer {
    /// Utils.Depth Reference.
    public var depth: Utils.UI.Depth {
        get {
            Utils.AssociatedObject.get(base: self, key: &DepthKey) {
                .zero
            }
        }
        set {
            Utils.AssociatedObject.set(base: self, key: &DepthKey, value: newValue)
            
            shadowOffset = newValue.offset.asSize
            shadowOpacity = newValue.opacity
            shadowRadius = newValue.radius
            
            layoutDepthPath()
        }
    }
    
    /// Sets the shadow path.
    public func layoutDepthPath() {
        if depth.isZero {
            shadowPath = nil
        } else {
            shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        }
    }
}
