//
//  UITraitCollection+.swift
//  
//
//  Created by Miroslav Yozov on 27.07.20.
//

import UIKit

public extension UITraitCollection {
    var isiPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    var isiPhoneLandscape: Bool {
        verticalSizeClass == .compact
    }
}
