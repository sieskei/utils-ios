//
//  NSLayoutConstraint+.swift
//  
//
//  Created by Miroslav Yozov on 23.07.21.
//

import UIKit

public extension NSLayoutConstraint {
    func activate() -> Self {
        isActive = true
        return self
    }
    
    func multiplied(_ multiplier: CGFloat) -> NSLayoutConstraint {
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
