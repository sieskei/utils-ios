//
//  Label.swift
//  
//
//  Created by Miroslav Yozov on 30.03.20.
//

import UIKit

public class Label: UILabel {
    public var insets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override public var intrinsicContentSize: CGSize {
        get {
            var cs = super.intrinsicContentSize
            cs.height += insets.top + insets.bottom
            cs.width += insets.left + insets.right
            return cs
       }
    }
}
