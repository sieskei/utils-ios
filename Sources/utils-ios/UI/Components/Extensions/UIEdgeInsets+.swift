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
}
