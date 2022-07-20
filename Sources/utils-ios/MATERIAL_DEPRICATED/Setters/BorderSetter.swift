//
//  BorderSetter.swift
//  
//
//  Created by Miroslav Yozov on 30.03.20.
//

import UIKit
import Material

@objc
public protocol BorderSetter {
    dynamic func set(borderColor color: UIColor)
    dynamic func set(borderWidthPreset width: BorderWidthPreset)
}

extension UIView: BorderSetter {
    public func set(borderColor color: UIColor) {
        self.borderColor = color
    }
    
    public func set(borderWidthPreset width: BorderWidthPreset) {
        self.borderWidthPreset = width
    }
}
