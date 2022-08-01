//
//  NSLayoutConstraint+Ext.swift
//  
//
//  Created by Miroslav Yozov on 7.07.22.
//

import UIKit

extension NSLayoutXAxisAnchor {
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: c).with(multiplier: m)
    }

    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: c).with(multiplier: m)
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: c).with(multiplier: m)
    }
}

extension NSLayoutYAxisAnchor {
    func constraint(equalTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: c).with(multiplier: m)
    }

    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: c).with(multiplier: m)
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: c).with(multiplier: m)
    }
}

fileprivate extension NSLayoutConstraint {
    func with(multiplier: CGFloat) -> NSLayoutConstraint {
        .init(item: firstItem!, attribute: firstAttribute, relatedBy: relation, toItem: secondItem, attribute: secondAttribute, multiplier: multiplier, constant: constant)
    }
}

public extension NSLayoutConstraint {
    @discardableResult
    func activate() -> Self {
        isActive = true
        return self
    }
    
    func multiplied(_ multiplier: CGFloat) -> NSLayoutConstraint {
        guard self.multiplier != multiplier else {
            return self
        }
        
        let c: NSLayoutConstraint = .init(item: firstItem as Any,
                                          attribute: firstAttribute,
                                          relatedBy: relation,
                                          toItem: secondItem,
                                          attribute: secondAttribute,
                                          multiplier: multiplier,
                                          constant: constant)
        if isActive {
            isActive = false
            c.isActive = true
        }
        
        return c
    }
}
