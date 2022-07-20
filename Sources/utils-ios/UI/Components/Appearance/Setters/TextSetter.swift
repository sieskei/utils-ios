//
//  TextSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit

@objc
public protocol UtilsUITextSetter {
    dynamic func set(text: String)
}

extension UILabel: UtilsUITextSetter {
    public func set(text: String) {
        self.text = text
    }
}
