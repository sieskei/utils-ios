//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

extension Utils.UI {
    open class Color: UIColor {
        // dark text
        open class darkText {
            public static let primary = Color.black.withAlphaComponent(0.87)
            public static let secondary = Color.black.withAlphaComponent(0.54)
            public static let others = Color.black.withAlphaComponent(0.38)
            public static let dividers = Color.black.withAlphaComponent(0.12)
        }
      
        // light text
        open class lightText {
            public static let primary = Color.white
            public static let secondary = Color.white.withAlphaComponent(0.7)
            public static let others = Color.white.withAlphaComponent(0.5)
            public static let dividers = Color.white.withAlphaComponent(0.12)
        }
    }
}
