//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 30.07.21.
//

import UIKit

extension UIEdgeInsets {
    public static var leastNormalMagnitude: UIEdgeInsets {
        .init(repeating: .leastNormalMagnitude)
    }
    
    public var vertical: CGFloat {
        return top + bottom
    }
    
    public var horizontal: CGFloat {
        return left + right
    }
    
    public init(repeating value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
    
    public init(_ value: UIEdgeInsets, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        self.init(top: top ?? value.top, left: left ?? value.left, bottom: bottom ?? value.bottom, right: right ?? value.right)
    }
    
    public func set(top value: CGFloat) -> Self {
        .init(self, top: value)
    }
    
    public func set(bottom value: CGFloat) -> Self {
        .init(self, bottom: value)
    }
    
    public func set(left value: CGFloat) -> Self {
        .init(self, left: value)
    }
    
    public func set(right value: CGFloat) -> Self {
        .init(self, right: value)
    }
}
