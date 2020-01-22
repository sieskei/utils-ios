//
//  FontSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit

@objc
public protocol FontSetter {
    dynamic func set(font: UIFont)
    dynamic func set(fontSize size: CGFloat)
    dynamic func set(fontColor color: UIColor)
}

@objc
public protocol FontStateSetter: FontSetter {
    dynamic func set(fontColor color: UIColor, for state: UIControl.State)
}

extension UILabel: FontSetter {
    public func set(font: UIFont) {
        self.font = font
    }
    
    public func set(fontSize size: CGFloat) {
        self.fontSize = size
    }
    
    public func set(fontColor color: UIColor) {
        self.textColor = color
    }
}

extension UITextField: FontSetter {
    public func set(font: UIFont) {
        self.font = font
    }
    
    public func set(fontSize size: CGFloat) {
        print("UITextField.FontSetter: \(#selector(UITextField.set(fontSize:))) not supported, use \(#selector(UITextField.set(font:))) instead.")
    }
    
    public func set(fontColor color: UIColor) {
        self.textColor = color
    }
}
