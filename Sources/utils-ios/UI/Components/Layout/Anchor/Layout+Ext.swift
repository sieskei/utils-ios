//
//  Layout+Ext.swift
//  
//
//  Created by Miroslav Yozov on 7.07.22.
//

import UIKit

extension CGFloat {
    public init<T: BinaryFloatingPoint>(_ value: T) {
        switch value {
        case is Double:
            self.init(value as! Double)
        case is Float:
            self.init(value as! Float)
        case is CGFloat:
            self.init(value as! CGFloat)
        default:
            fatalError("Unable to initialize CGFloat with value \(value) of type \(type(of: value))")
        }
    }
}

extension Float {
    public init<T: BinaryFloatingPoint>(_ value: T) {
        switch value {
        case is Double:
            self.init(value as! Double)
        case is Float:
            self.init(value as! Float)
        case is CGFloat:
            self.init(value as! CGFloat)
        default:
            fatalError("Unable to initialize CGFloat with value \(value) of type \(type(of: value))")
        }
    }
}

extension UIEdgeInsets {
    internal init(constant c: CGFloat) {
        self.init(top: c, left: c, bottom: c, right: c)
    }
}

internal prefix func - (rhs: UIEdgeInsets) -> UIEdgeInsets {
    .init(top: -rhs.top, left: -rhs.left, bottom: -rhs.bottom, right: -rhs.right)
}
