//
//  TextSetter.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import UIKit

@objc
public protocol TextSetter {
    dynamic func set(text: String)
}

extension UILabel: TextSetter {
    public func set(text: String) {
        self.text = text
    }
}
