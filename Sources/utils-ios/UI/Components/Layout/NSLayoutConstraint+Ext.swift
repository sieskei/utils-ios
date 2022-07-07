//
//  NSLayoutConstraint+Ext.swift
//  
//
//  Created by Miroslav Yozov on 7.07.22.
//

import UIKit

extension NSLayoutXAxisAnchor {
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = constraint(equalTo: anchor, constant: c)
        return constraint.with(multiplier: m)
    }

    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        return constraint.with(multiplier: m)
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        return constraint.with(multiplier: m)
    }
}

extension NSLayoutYAxisAnchor {
    func constraint(equalTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = constraint(equalTo: anchor, constant: c)
        return constraint.with(multiplier: m)
    }

    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        return constraint.with(multiplier: m)
    }

    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, multiplier m: CGFloat, constant c: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        return constraint.with(multiplier: m)
    }
}

fileprivate extension NSLayoutConstraint {
    func with(multiplier: CGFloat) -> NSLayoutConstraint {
        .init(item: firstItem!, attribute: firstAttribute, relatedBy: relation, toItem: secondItem, attribute: secondAttribute, multiplier: multiplier, constant: constant)
    }
}
