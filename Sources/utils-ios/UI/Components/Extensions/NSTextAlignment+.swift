//
//  NSTextAlignment+.swift
//  
//
//  Created by Miroslav Yozov on 4.03.20.
//

import UIKit

extension NSTextAlignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .left:
            return "left"
        case .center:
            return "center"
        case .right:
            return "right"
        case .justified:
            return "justified"
        case .natural:
            return "natural"
        @unknown default:
            return ""
        }
    }
}
