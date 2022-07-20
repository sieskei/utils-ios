//
//  CornerRadiusSetter.swift
//  
//
//  Created by Miroslav Yozov on 30.03.20.
//

import UIKit
import Material

@objc
public protocol CornerRadiusSetter {
    dynamic func set(cornerRadiusPreset width: CornerRadiusPreset)
}

extension UIView: CornerRadiusSetter {
    public func set(cornerRadiusPreset width: CornerRadiusPreset) {
        self.cornerRadiusPreset = width
    }
}
