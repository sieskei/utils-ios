//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 26.07.22.
//

import UIKit

extension Utils.UI {
    public class InsetedTextField: UITextField {
        public var inset: CGFloat = 0
    
        public override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: inset, dy: inset)
        }
    
        public override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return textRect(forBounds: bounds)
        }
    }
}
