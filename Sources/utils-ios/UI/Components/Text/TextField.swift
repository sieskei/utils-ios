//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 25.10.20.
//

import UIKit

public class TextField: UITextField {
    public var inset: CGFloat = 0

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
