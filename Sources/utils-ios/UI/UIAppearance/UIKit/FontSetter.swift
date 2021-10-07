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

extension UIButton: FontStateSetter {
    public func set(font: UIFont) {
        self.titleLabel?.font = font
    }

    public func set(fontSize size: CGFloat) {
        guard let title = titleLabel, let font = title.font else {
            return
        }
        title.font = font.withSize(size)
    }

    public func set(fontColor color: UIColor) {
        setTitleColor(color, for: .normal)
        setTitleColor(color, for: .highlighted)
        setTitleColor(color, for: .disabled)
        setTitleColor(color, for: .selected)

        if #available(iOS 9, *) {
          setTitleColor(color, for: .application)
          setTitleColor(color, for: .focused)
          setTitleColor(color, for: .reserved)
        }
    }

    public func set(fontColor color: UIColor, for state: UIControl.State) {
        self.setTitleColor(color, for: state)
    }
}
