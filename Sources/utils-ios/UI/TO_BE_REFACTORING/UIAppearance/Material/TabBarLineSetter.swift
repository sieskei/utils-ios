//
//  TabBarLineSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit
import Material

@objc
public protocol TabBarLineSetter {
    dynamic func set(lineColor color: UIColor)
    dynamic func set(lineHeight height: CGFloat)
    dynamic func set(lineAlignment alignment: TabBarLineAlignment)
}

extension TabBar: TabBarLineSetter {
    public func set(lineColor color: UIColor) {
        self.lineColor = color
    }
    
    public func set(lineHeight height: CGFloat) {
        self.lineHeight = height
    }
    
    public func set(lineAlignment alignment: TabBarLineAlignment) {
        self.lineAlignment = alignment
    }
}

