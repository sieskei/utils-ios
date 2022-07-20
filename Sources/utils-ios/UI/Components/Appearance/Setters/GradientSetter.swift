//
//  GradientSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit

@objc
public protocol UtilsUIGradientSetter {
    dynamic func set(fullVericalGradientColors colors: [UIColor])
}

extension Utils.UI.GradientView: UtilsUIGradientSetter {
    public func set(fullVericalGradientColors colors: [UIColor]) {
        applyGradient(withColours: colors, orientation: .vertical, location: .fullScreen)
    }
}
