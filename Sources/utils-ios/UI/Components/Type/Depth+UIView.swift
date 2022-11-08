//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 7.11.22.
//

import UIKit

fileprivate var DepthLayerKey: UInt8 = 0

extension UIView {
    /// Utils.Depth Reference.
    public var depthLayer: CALayer {
        Utils.AssociatedObject.get(base: self, key: &DepthLayerKey) {
            let depthLayer: CAShapeLayer = .init()
            layer.insertSublayer(depthLayer, at: .zero)
            return depthLayer
        }
    }
}
