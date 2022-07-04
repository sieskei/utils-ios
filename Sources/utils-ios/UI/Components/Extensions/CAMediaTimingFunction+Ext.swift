//
//  CAMediaTimingFunction+Ext.swift
//  
//
//  Created by Miroslav Yozov on 29.06.22.
//

import UIKit

public extension CAMediaTimingFunction {
    //  Default
    static let linear:    CAMediaTimingFunction = .init(name: CAMediaTimingFunctionName.linear)
    static let easeIn:    CAMediaTimingFunction = .init(name: CAMediaTimingFunctionName.easeIn)
    static let easeOut:   CAMediaTimingFunction = .init(name: CAMediaTimingFunctionName.easeOut)
    static let easeInOut: CAMediaTimingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
  
    //  Material
    static let standard:     CAMediaTimingFunction = .init(controlPoints: 0.4, 0.0, 0.2, 1.0)
    static let deceleration: CAMediaTimingFunction = .init(controlPoints: 0.0, 0.0, 0.2, 1)
    static let acceleration: CAMediaTimingFunction = .init(controlPoints: 0.4, 0.0, 1, 1)
    static let sharp:        CAMediaTimingFunction = .init(controlPoints: 0.4, 0.0, 0.6, 1)
  
    // Easing.net
    static let easeOutBack: CAMediaTimingFunction = .init(controlPoints: 0.175, 0.885, 0.32, 1.75)
}
