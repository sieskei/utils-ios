//
//  CGRect+.swift
//  
//
//  Created by Miroslav Yozov on 23.07.22.
//

import UIKit

public extension CGRect {
    static var one: CGRect {
        .init(origin: .zero, size: .init(width: 1, height: 1))
    }
    
    /// A center point based on the origin and size values.
    var center: CGPoint {
        .init(x: origin.x + width / 2, y: origin.y + height / 2)
    }
}
